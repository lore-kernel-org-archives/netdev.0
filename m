From: "Y.B. Lu" <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Subject: RE: [v15, 6/7] base: soc: introduce soc_device_match() interface
Date: Mon, 31 Oct 2016 09:28:56 +0000
Message-ID: <DB6PR0401MB2536CAD001BF3CAB4EDB15DCF8AE0@DB6PR0401MB2536.eurprd04.prod.outlook.com>
References: <1477637418-38938-1-git-send-email-yangbo.lu@nxp.com>
	<1477637418-38938-7-git-send-email-yangbo.lu@nxp.com>
	<2572890.e6aV4hmMEL@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"M.H. Lian" <minghuan.lian-3arQi8VN3Tc@public.gmane.org>,
	"linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Qiang Zhao <qiang.zhao-3arQi8VN3Tc@public.gmane.org>, Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Bhupesh Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Kumar
	Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, Scott Wood <oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-mmc
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, "linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org"
	<linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2572890.e6aV4hmMEL@wuerfel>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Arnd Bergmann [mailto:arnd-r2nGTMty4D4@public.gmane.org]
> Sent: Friday, October 28, 2016 6:48 PM
> To: linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
> Cc: Y.B. Lu; linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org; Scott
> Wood; Mark Rutland; Greg Kroah-Hartman; X.B. Xie; M.H. Lian; linux-
> i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Qiang Zhao; Russell King;
> Bhupesh Sharma; Joerg Roedel; Claudiu Manoil; devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> Rob Herring; Santosh Shilimkar; linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org;
> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Leo Li;
> iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org; Kumar Gala; Geert Uytterhoeven
> Subject: Re: [v15, 6/7] base: soc: introduce soc_device_match() interface
> 
> On Friday, October 28, 2016 2:50:17 PM CEST Yangbo Lu wrote:
> > +
> > +static int soc_device_match_one(struct device *dev, void *arg) {
> > +       struct soc_device *soc_dev = container_of(dev, struct
> soc_device, dev);
> > +       const struct soc_device_attribute *match = arg;
> > +
> > +       if (match->machine &&
> > +           !glob_match(match->machine, soc_dev->attr->machine))
> > +               return 0;
> > +
> > +       if (match->family &&
> > +           !glob_match(match->family, soc_dev->attr->family))
> > +               return 0;
> > +
> >
> 
> Geert found a bug in my code, and submitted a fix at
> https://patchwork.kernel.org/patch/9361395/
> 
> I think you should include that one in your series.
> 

[Lu Yangbo-B47093] Ok, no problem. Thanks :)

> 	Arnd
