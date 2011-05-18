From: Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>
Subject: Re: net-next-2.6 wireless build failure
Date: Wed, 18 May 2011 23:38:22 +0300
Message-ID: <1305751102.12586.1546.camel@cumari>
References: <20110518.155501.486816316237445149.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org, eliad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110518.155501.486816316237445149.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

On Wed, 2011-05-18 at 15:55 -0400, David Miller wrote:
> The suspend op member of ieee80211_ops is only available when
> CONFIG_PM is enabled.
>=20
> drivers/net/wireless/wl12xx/main.c:3653:2: error: unknown field =E2=80=
=98suspend=E2=80=99 specified in initializer
> drivers/net/wireless/wl12xx/main.c:3653:2: warning: initialization fr=
om incompatible pointer type [enabled by default]
> drivers/net/wireless/wl12xx/main.c:3653:2: warning: (near initializat=
ion for =E2=80=98wl1271_ops.config=E2=80=99) [enabled by default]
> drivers/net/wireless/wl12xx/main.c:3654:2: error: unknown field =E2=80=
=98resume=E2=80=99 specified in initializer
> drivers/net/wireless/wl12xx/main.c:3654:2: warning: initialization fr=
om incompatible pointer type [enabled by default]
> drivers/net/wireless/wl12xx/main.c:3654:2: warning: (near initializat=
ion for =E2=80=98wl1271_ops.bss_info_changed=E2=80=99) [enabled by defa=
ult]
>=20
> Someone please fix this.

I'm really sorry to let this pass through.  I'll send a patch to fix it
in a second.

--=20
Cheers,
Luca.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
