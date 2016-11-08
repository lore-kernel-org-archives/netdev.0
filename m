From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [v15, 3/7] powerpc/fsl: move mpc85xx.h to include/linux/fsl
Date: Tue, 08 Nov 2016 16:47:00 +0100
Message-ID: <2774358.lRZpWbmlT7@wuerfel>
References: <1477637418-38938-1-git-send-email-yangbo.lu@nxp.com> <1543282.vWjeo4ynTa@wuerfel> <DB6PR0401MB25366BC8FF59C68E2823245EF8A60@DB6PR0401MB2536.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
        "linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Scott Wood <oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        "X.B. Xie" <xiaobo.xie-3arQi8VN3Tc@public.gmane.org>,
        "M.H. Lian" <minghuan.lian-3arQi8VN3Tc@public.gmane.org>,
        "linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Qiang Zhao <qiang.zhao-3arQi8VN3Tc@public.gmane.org>,
        Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
        Bhupesh Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
        Joerg Roedel <joro-zLv9SwRftAIdnm+yROfE0A@public.gmane.org>,
        Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
To: "Y.B. Lu" <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <DB6PR0401MB25366BC8FF59C68E2823245EF8A60-2mNvjAGDOPkZcyyZo0JLBI3W/0Ik+aLCnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday, November 8, 2016 6:49:51 AM CET Y.B. Lu wrote:
> Hi Arnd,
> 
> 
> > -----Original Message-----
> > From: Arnd Bergmann [mailto:arnd-r2nGTMty4D4@public.gmane.org]
> > Sent: Tuesday, November 08, 2016 5:20 AM
> > To: Y.B. Lu
> > Cc: linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org; linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> > ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org; Scott Wood; Mark Rutland; Greg Kroah-Hartman; X.B.
> > Xie; M.H. Lian; linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> > Qiang Zhao; Russell King; Bhupesh Sharma; Joerg Roedel; Claudiu Manoil;
> > devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Rob Herring; Santosh Shilimkar; linux-arm-
> > kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-
> > kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Leo Li; iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org; Kumar
> > Gala
> > Subject: Re: [v15, 3/7] powerpc/fsl: move mpc85xx.h to include/linux/fsl
> > 
> > On Monday, October 31, 2016 9:35:33 AM CET Y.B. Lu wrote:
> > > >
> > > > I don't see any of the contents of this header referenced by the soc
> > > > driver any more. I think you can just drop this patch.
> > > >
> > >
> > > [Lu Yangbo-B47093] This header file was included by guts.c.
> > > The guts driver used macro SVR_MAJ/SVR_MIN for calculation.
> > >
> > > This header file was for powerpc arch before. And this patch is to
> > > made it as common header file for both ARM and PPC.
> > > Sooner or later this is needed.
> > 
> > Let's discuss it once we actually need the header then, ok?
> 
> [Lu Yangbo-B47093] As I said, this header file was included by guts.c in patch 4.

Ah sorry, I misread your earlier reply, thinking you meant a potential
future patch.

> The guts driver used macro SVR_MAJ/SVR_MIN for calculation which were
> defined in this header file.
> Did you suggest we dropped this patch and just calculated them in driver?

That is probably nicer here: there is not that much value in sharing
the two one-line macro definitions, and the driver already hardcodes
the numeric per-chip IDs that make up most of the header file.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
