From: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [PATCH 1/7] Documentation: dt: net: Update the ath9k binding for SoC devices
Date: Tue, 28 Mar 2017 19:09:00 +0200
Message-ID: <5695498.VIMxqRcvSt@debian64>
References: <1489439116-4233-1-git-send-email-albeu@free.fr> <8622591.q4sXytZqXW@debian64> <20170328164159.GB29742@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Alban <albeu-GANU6spQydw@public.gmane.org>,
        QCA ath9k Development <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        m@kresin.me
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170328164159.GB29742-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday, March 28, 2017 6:41:59 PM CEST Andrew Lunn wrote:
> > Oh, in that case you should probably go "all out" and ask on the 
> > LKML to remove all of the ath9k and ath10k ahb work. From what I
> > know all the "users" are running some sort of OpenWRT/LEDE or a 
> > derivative. This is because Atheros/QCA provided a SDK based on
> > OpenWRT.
> > 
> > Alban has been trying to convert the platform to device-tree
> > and add them to the mainline for a while now:
> >  
> > https://patchwork.kernel.org/patch/6514551/
> > 
> > So, you are questioning this work as well.
> 
> Not at all. Ralph Sennhauser has been doing a great job of getting all
> the Marvell devices into Mainline, and i help as much as i can, being
> one of the Marvell SoC Maintainers.
> 
> I'm just saying, get a few boards which require these facilities into
> the mainline, and then you have a much stronger base to argue from.

I was arguing not to deprecate "qca,no-eeprom" property.

based on this quote from Linus' <https://lkml.org/lkml/2016/6/16/995>:
|if a new interface is truly more flexible, then it should be able
|to implement the old interface with no changes, so that drivers
|shouldn't need to be changed/upgraded.

what stronger point to do you want?

Thanks,
Christian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
