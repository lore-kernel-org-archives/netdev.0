From: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH v13 0/6] flexcan: Add support for powerpc flexcan
	(freescale p1010)
Date: Tue, 18 Oct 2011 06:43:13 -0500
Message-ID: <D79CB818-C14E-4C8D-9A8D-42B39ADE20B2@kernel.crashing.org>
References: <1313551944-28603-1-git-send-email-holt@sgi.com>
	<16FBAA47-5133-43A1-80CE-C6D63B79FB5D@kernel.crashing.org>
	<20111018094328.GC22814@sgi.com>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20111018094328.GC22814-sJ/iWh9BUns@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org


>> Robin,
>> 
>> Do you remember why we went with just 'fsl,p1010-flexcan' as the device tree compatible?  Do we feel the flex can on P1010 isn't the same as on MPC5xxx? or the ARM SoCs?
> 
> The decision was due to the fact there is no true "generic" fsl.flexcan
> chip free of any SOC implementation and therefore not something which
> could be separately defined.  That decision was made by Grant Likely.
> I will inline that email below.
> 
> Robin


Thanks, I'll look into this internally at FSL.  I think its confusing as hell to have "fsl,p1010-flexcan" in an ARM .dts and don't think any reasonable ARM customer of FSL would know to put a PPC SOC name in their .dts.  I'll ask the HW guys what's going on so we can come up with a bit more generic name so we don't have to constantly change this.  Even if its just:

fsl,ppc-flexcan & fsl,arm-flexcan.

> On Mon, Aug 15, 2011 at 09:13:50AM -0600, Grant Likely wrote:
>> On Mon, Aug 15, 2011 at 9:03 AM, Robin Holt <holt-sJ/iWh9BUns@public.gmane.org> wrote:
>>> Grant,
>>> 
>>> Earlier, you had asked for a more specific name for the compatible
>>> property of the Freescale flexcan device.  I still have not gotten a
>>> more specific answer.  Hopefully Marc can give you more details about
>>> the flexcan implementations.
>> 
>> If there is no ip core version, then just stick with the
>> fsl,<soc>-flexcan name and drop "fsl,flexcan".  Marketing may say
>> flexcan is flexcan, but hardware engineers like to change things.
>> Trying to be too generic in compatible values will just lead to
>> problems in the future.
> 
> Thanks,
> Robin

- k
