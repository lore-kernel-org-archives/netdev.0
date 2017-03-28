From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 1/7] Documentation: dt: net: Update the ath9k binding for
 SoC devices
Date: Tue, 28 Mar 2017 17:18:37 +0200
Message-ID: <20170328151837.GC3152@lunn.ch>
References: <1489439116-4233-1-git-send-email-albeu@free.fr>
 <1897671.fKa4XTnU1K@debian64>
 <20170328104441.5feedcf4@avionic-0020>
 <2357006.NGKQYCh4BG@debian64>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alban <albeu-GANU6spQydw@public.gmane.org>,
        QCA ath9k Development <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        m@kresin.me
To: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2357006.NGKQYCh4BG@debian64>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> But LEDE/OpenWRT rely on the firmware loading API more than ever and 
> currently there is not a replacement for it.

....


> I looked into 10-ath9k-eeprom [0] of LEDE's AR71XX target and I noticed
> that quite a few devices patch the MACs of the wifi.
> If you look at the code for the Airtight C-55 and C-60, Meraki MR18,
> Meraki Z1, you'll notice that each one has to add a fixed value (+1,
> +2, ...) to the extraced MAC-Address. So how would you replicate this,
> with "nvmem-cell-names = address" without some sort of 
> nvmem-provider-processor?

...
 
> https://github.com/lede-project/source/blob/master/target/linux/ar71xx/files/arch/mips/ath79/dev-eth.c#L1204
> 
> and grep lists the following devices:
> mach-dgl-5500-a1.c, mach-dhp-1565-a1.c, mach-dir-505-a1.c, mach-dir-615-c1.c
> mach-dir-615-i1.c, mach-dir-825-b1.c, mach-dir-825-c1.c, mach-tew-673gru.c
> mach-tew-712br.c, mach-tew-732br.c, mach-tew-823dru.c

I would say a big part of the problem is that all of these use cases
are outside of mainline. Why should mainline support something which
is not actually used in mainline.

So i would suggest your first step is to bring some of these devices
into mainline. Once in mainline, it becomes a mainline issue, and
people will help get it solved.

       Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
