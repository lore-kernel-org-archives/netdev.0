From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v4 10/10] ARM: sunxi: Enable sun8i-emac driver on
 multi_v7_defconfig
Date: Wed, 12 Oct 2016 10:36:15 +0200
Message-ID: <20161012083615.GA23377@Red>
References: <1475828757-926-1-git-send-email-clabbe.montjoie@gmail.com>
 <1475828757-926-11-git-send-email-clabbe.montjoie@gmail.com>
 <20161010123046.GH3462@lukather>
 <20161010123511.GA16103@Red>
 <20161010150943.fa7ca85fe52f4c6f9508b5eb@free.fr>
 <20161011094042.GS3462@lukather>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jean-Francois Moine <moinejf@free.fr>, mark.rutland@arm.com,
        andrew@lunn.ch, f.fainelli@gmail.com, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux@armlinux.org.uk,
        linux-kernel@vger.kernel.org, wens@csie.org, robh+dt@kernel.org,
        davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36390 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932201AbcJLIgT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 04:36:19 -0400
Content-Disposition: inline
In-Reply-To: <20161011094042.GS3462@lukather>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 11, 2016 at 11:40:42AM +0200, Maxime Ripard wrote:
> On Mon, Oct 10, 2016 at 03:09:43PM +0200, Jean-Francois Moine wrote:
> > On Mon, 10 Oct 2016 14:35:11 +0200
> > LABBE Corentin <clabbe.montjoie@gmail.com> wrote:
> > 
> > > On Mon, Oct 10, 2016 at 02:30:46PM +0200, Maxime Ripard wrote:
> > > > On Fri, Oct 07, 2016 at 10:25:57AM +0200, Corentin Labbe wrote:
> > > > > Enable the sun8i-emac driver in the multi_v7 default configuration
> > > > > 
> > > > > Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> > > > > ---
> > > > >  arch/arm/configs/multi_v7_defconfig | 1 +
> > > > >  1 file changed, 1 insertion(+)
> > > > > 
> > > > > diff --git a/arch/arm/configs/multi_v7_defconfig b/arch/arm/configs/multi_v7_defconfig
> > > > > index 5845910..f44d633 100644
> > > > > --- a/arch/arm/configs/multi_v7_defconfig
> > > > > +++ b/arch/arm/configs/multi_v7_defconfig
> > > > > @@ -229,6 +229,7 @@ CONFIG_NETDEVICES=y
> > > > >  CONFIG_VIRTIO_NET=y
> > > > >  CONFIG_HIX5HD2_GMAC=y
> > > > >  CONFIG_SUN4I_EMAC=y
> > > > > +CONFIG_SUN8I_EMAC=y
> > > > 
> > > > Any reason to build it statically?
> > > 
> > > No, just copied the same than CONFIG_SUN4I_EMAC that probably do
> > > not need it also.
> > 
> > All arm configs are done the same way, and, some day, the generic ARM
> > V7 kernel will not be loadable in 1Gb RAM...
> 
> Yeah, if possible, I'd really like to avoid introducing statically
> built drivers to multi_v7.
> 

I forgot to said it in my first answer, but yes I will change it.

Regards
