From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH v13 0/6] flexcan: Add support for powerpc flexcan
	(freescale p1010)
Date: Tue, 18 Oct 2011 09:13:53 +0200
Message-ID: <4E9D2731.4010800@grandegger.com>
References: <1313551944-28603-1-git-send-email-holt@sgi.com>
	<16FBAA47-5133-43A1-80CE-C6D63B79FB5D@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <16FBAA47-5133-43A1-80CE-C6D63B79FB5D-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
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

Hi Kumar,

On 10/18/2011 07:44 AM, Kumar Gala wrote:
> 
> On Aug 16, 2011, at 10:32 PM, Robin Holt wrote:
> 
>> David,
>>
>> The following set of patches have been reviewed by the above parties and
>> all comments have been integrated.  Although the patches stray from the
>> drivers/net/can directory, the diversions are related to changes for
>> the flexcan driver.
>>
>> The patch set is based upon your net-next-2.6 tree's commit 6c37e46.
>>
>> Could you please queue these up for the next appropriate push to Linus'
>> tree?
>>
>> Thanks,
>> Robin Holt
> 
> Robin,
> 
> Do you remember why we went with just 'fsl,p1010-flexcan' as the device tree compatible?  Do we feel the flex can on P1010 isn't the same as on MPC5xxx? or the ARM SoCs?

The MPC5xxx SOCs have a MSCAN controller, which is different to the
Flexcan and handled by another driver. But the Flexcan's  on the
Freescale ARM SOCs are identical and supported by that driver as well
and "fsl,flexcan" would work *perfectly*. Actually Grant instructed use
to be more explicit and use "fsl,p1010-flexcan". Anyway,
"fsl,p1010-flexcan" should work on ARM SOCs if the source frequency is
provided via boot loader or the DTS file. Compatibility was one of our
main concerns.

Wolfgang.
