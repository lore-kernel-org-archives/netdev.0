From: Shawn Guo <shawn.guo-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Subject: Re: [PATCH 2/3] net/fec: add device tree support
Date: Sun, 19 Jun 2011 15:46:59 +0800
Message-ID: <20110619074658.GD23171@S2100-06.ap.freescale.net>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
	<1308410354-21387-3-git-send-email-shawn.guo@linaro.org>
	<20110618162220.GI8195@ponder.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Jason Liu <jason.hui-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110618162220.GI8195-e0URQFbLeQY2iJbIjFUEsiwD8/FfD2ys@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 18, 2011 at 10:22:20AM -0600, Grant Likely wrote:
> On Sat, Jun 18, 2011 at 11:19:13PM +0800, Shawn Guo wrote:
> > It adds device tree data parsing support for fec driver.
> > 
> > Signed-off-by: Jason Liu <jason.hui-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> > Signed-off-by: Shawn Guo <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> > Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> > ---
> >  Documentation/devicetree/bindings/net/fsl-fec.txt |   14 ++++++++++
> >  drivers/net/fec.c                                 |   28 +++++++++++++++++++++
> >  2 files changed, 42 insertions(+), 0 deletions(-)
> >  create mode 100644 Documentation/devicetree/bindings/net/fsl-fec.txt
> > 
> > diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
> > new file mode 100644
> > index 0000000..705111d
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
> > @@ -0,0 +1,14 @@
> > +* Freescale Fast Ethernet Controller (FEC)
> > +
> > +Required properties:
> > +- compatible : should be "fsl,<soc>-fec", "fsl,fec"
> 
> Ditto to comment on last patch.  "fsl,fec" is to generic.
> "fsl,imx51-soc" should be the generic value.
> 

Ditto to the feedback on the last comment.  "fsl,imx51-fec" is not
a good one to be the compatibility string for imx27 and imx35 fec.

> Otherwise looks okay to me, and I don't see any problem with queueing
> it up for v3.1 with that change since it doesn't depend on any other
> patches.
> 
> Acked-by: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
> 

-- 
Regards,
Shawn
