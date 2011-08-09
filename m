From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH 5/5] [powerpc] Fix up fsl-flexcan device tree binding.
Date: Tue, 09 Aug 2011 21:32:09 +0200
Message-ID: <4E418B39.6040408@grandegger.com>
References: <1312901031-29887-1-git-send-email-holt@sgi.com>
	<1312901031-29887-6-git-send-email-holt@sgi.com>
	<4E4179CB.6030101@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org"
	<Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
To: Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4E4179CB.6030101-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
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

On 08/09/2011 08:17 PM, Scott Wood wrote:
> On 08/09/2011 09:43 AM, Robin Holt wrote:
>> In working with the socketcan developers, we have come to the conclusion
>> the fsl-flexcan device tree bindings need to be cleaned up. 
>> The driver does not depend upon any properties other than the required properties
>> so we are removing the file.
> 
> That is not the criterion for whether something should be expresed in
> the device tree.  It's a description of the hardware, not a Linux driver
> configuration file.  If there are integration parameters that can not be
> inferred from "this is FSL flexcan v1.0", they should be expressed in
> the node.
> 
> Removing the binding altogether seems extreme as well -- we should have
> bindings for all devices, even if there are no special properties.

Yes, of course. The commit message misleading. We do not intend to
remove the binding but just a few unused and confusing properties.
Concerning the compatible string, Freescale introduced for the Flexcan
on the P1010 "fsl,flexcan-v1.0". That's not the usual convention also
because the v1.0 if for the PowerPC cores only, I assume, but we have
ARM cores as well. If we need to distinguish I think we should use:

  "fsl,p1010-flexcan", "fsl,flexcan"

Do you agree?

>> Additionally, the p1010*dts files are not
>> following the standard for node naming in that they have a trailing -v1.0.
> 
> What "standard for node naming"?  There's nothing wrong with putting a
> block version number in the compatible string, and it looks like the
> p1010 dts files were following the binding document in this regard.  It
> is common practice when the block version is publicly documented but
> there's no register it can be read from at runtime.

See above.

Furthermore I must admit, that the bindings shown up mainline Linux have
never been presented on any mailing list.

Wolfgang.
