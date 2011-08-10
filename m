From: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [PATCH v11 5/5] powerpc: Fix up fsl-flexcan device tree binding.
Date: Wed, 10 Aug 2011 13:45:38 -0500
Message-ID: <20110810184538.GA4926@sgi.com>
References: <1312993670-23999-1-git-send-email-holt@sgi.com>
	<1312993670-23999-6-git-send-email-holt@sgi.com>
	<4E42B83C.2040705@freescale.com> <20110810171933.GW4926@sgi.com>
	<4E42C196.7030708@freescale.com> <20110810183016.GY4926@sgi.com>
	<4E42D09E.4080405@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E42D09E.4080405-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
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

On Wed, Aug 10, 2011 at 01:40:30PM -0500, Scott Wood wrote:
> On 08/10/2011 01:30 PM, Robin Holt wrote:
> > On Wed, Aug 10, 2011 at 12:36:22PM -0500, Scott Wood wrote:
> >> On 08/10/2011 12:19 PM, Robin Holt wrote:
> >>> On Wed, Aug 10, 2011 at 11:56:28AM -0500, Scott Wood wrote:
> >>>> Also may want to list fsl,p1010-rdb as a "canonical compatible" for
> >>>> anything which is backwards compatible with p1010's implementation.
> >>>
> >>> How do I specify 'canonical compatible'?
> >>
> >> Something like:
> >>
> >>   compatible: Should be "fsl,<processor>-flexcan" and "fsl,flexcan".
> >>
> >>   An implementation should also claim any of the following compatibles
> >>   that it is fully backwards compatible with:
> >>
> >>   - fsl,p1010-rdb
> 
> Gah, I don't know how "rdb" replaced "flexcan" in the above.  Sorry for
> any confusion.
> 
> > I am so confused.  fsl,p1010-flexcan refers, in my mind at least, to
> > a particular chiplet on the p1010 freescale processor. 
> 
> It refers to a particular version of the flexcan logic, for which the
> hardware doc people weren't kind enough to give us a public version number.
> 
> It has been common and recommended practice in such cases, when there
> are multiple chips containing the same device, to pick a canonical chip
> (such as the first one to have the device or to be supported) and have
> others claim compatibility with it.
> 
> > fsl,p1010-rdb
> > would mean nothing to me as that is a p1010 processor with two flexcan
> > chiplets wired to a pair of DB-9 jacks.  For the driver, what additional
> > information is being conveyed?
> 
> The programming model of the flexcan chiplet.
> 
> > Let's cut to the chase.  Here is what I have after incorporating your
> > earlier comment about the compatible line.  Please mark this up to
> > exactly what you are asking for.
> > 
> > Thanks,
> > Robin
> > ------------------------------------------------------------------------
> > Flexcan CAN contoller on Freescale's ARM and PowerPC processors
> > 
> > Required properties:
> > 
> > - compatible : Should be "fsl,<processor>-flexcan" and "fsl,flexcan"
> 
>    An implementation should also claim any of the following compatibles
>    that it is fully backwards compatible with:
> 
>    - fsl,p1010-flexcan

Ah, there is my confusion.  I did not realize you were saying the
entire preceeding 4 lines should be included.  I thought you were
making a comment which I did not understand.

Thank you for your patience with my ignorance,
Robin
