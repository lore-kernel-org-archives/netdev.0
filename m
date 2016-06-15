From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211_hwsim: Allow wmediumd to attach to radios
 created in its netns
Date: Wed, 15 Jun 2016 10:10:17 +0200
Message-ID: <1465978217.2994.4.camel@sipsolutions.net>
References: <1463214884-5983-1-git-send-email-martin@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Martin Willi <martin-jzJueiEJWxp8fCCB1iTX4w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1463214884-5983-1-git-send-email-martin-jzJueiEJWxp8fCCB1iTX4w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I was about to apply this (with a typo fix for "responsile"), but
noticed these messages:

> =C2=A0	printk(KERN_DEBUG "mac80211_hwsim: received a REGISTER, "
> =C2=A0	=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0"switching to wmediu=
md mode with pid %d\n", info-
> >snd_portid);


> +	if (notify->portid =3D=3D hwsim_net_get_wmediumd(notify->net)) {
> =C2=A0		printk(KERN_INFO "mac80211_hwsim: wmediumd released
> netlink"
> =C2=A0		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0" socket, switching=
 to perfect channel
> medium\n");
>=20

I wonder if we can do something better about them? Or perhaps if we
should remove them, so other namespaces won't mess up the kernel log?

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
