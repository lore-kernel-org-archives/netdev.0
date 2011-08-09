From: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [PATCH 5/5] [powerpc] Fix up fsl-flexcan device tree binding.
Date: Tue, 9 Aug 2011 13:45:24 -0500
Message-ID: <20110809184524.GB4926@sgi.com>
References: <1312901031-29887-1-git-send-email-holt@sgi.com>
	<1312901031-29887-6-git-send-email-holt@sgi.com>
	<4E4179CB.6030101@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
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

On Tue, Aug 09, 2011 at 01:17:47PM -0500, Scott Wood wrote:
> On 08/09/2011 09:43 AM, Robin Holt wrote:
> > In working with the socketcan developers, we have come to the conclusion
> > the fsl-flexcan device tree bindings need to be cleaned up. 
> > The driver does not depend upon any properties other than the required properties
> > so we are removing the file.
> 
> That is not the criterion for whether something should be expresed in
> the device tree.  It's a description of the hardware, not a Linux driver
> configuration file.  If there are integration parameters that can not be
> inferred from "this is FSL flexcan v1.0", they should be expressed in
> the node.

There are no properties other than the required properties.  The others
were wrongly introduced and are not needed by the driver.  When we
removed the other properties and the wrong documentation of the mscan
oscillator source in the fsl-flexcan.txt file, we were left with an
Example: section and a one-line statement "The only properties supported
are the required properties."  That seemed like the fsl-flexcan.txt
file was then pointless.

> Removing the binding altogether seems extreme as well -- we should have
> bindings for all devices, even if there are no special properties.

Ok.  I can do that too.  Who is the definitive source for that answer?
I assume we are talking about the fsl-flexcan.txt file when we say
binding.  Is that correct?

> > Additionally, the p1010*dts files are not
> > following the standard for node naming in that they have a trailing -v1.0.
> 
> What "standard for node naming"?  There's nothing wrong with putting a

For the answer to that, you will need to ask Wolfgang Grandegger.  I was
working from his feedback.  Looking at the plethora of other node names,
the vast majority do not have any -v#.#, and the ones that do also tend
to have multiple versions. Based upon that, I suspect he is correct,
but I do not know where the documentation is or if it even exists.

> block version number in the compatible string, and it looks like the
> p1010 dts files were following the binding document in this regard.  It
> is common practice when the block version is publicly documented but
> there's no register it can be read from at runtime.

Thanks,
Robin
