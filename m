From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 3/4] mac80211: mesh: fixed HT ies in beacon template
Date: Wed, 29 Jun 2016 09:17:35 +0200
Message-ID: <1467184655.2461.2.camel@sipsolutions.net>
References: <20160628111307.8784-1-yanivma@ti.com>
 <20160628111307.8784-2-yanivma@ti.com>
 <20160628111307.8784-3-yanivma@ti.com>
	 <20160628111307.8784-4-yanivma@ti.com>
	 (sfid-20160628_131116_981554_64C22D92)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Meirav Kama <meiravk-l0cyMroinI0@public.gmane.org>
To: Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160628111307.8784-4-yanivma-l0cyMroinI0@public.gmane.org> (sfid-20160628_131116_981554_64C22D92)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-06-28 at 14:13 +0300, Yaniv Machani wrote:
>=C2=A0
> =C2=A0net/mac80211/mesh.c | 33 ++++++++++++++++++++++++++++++++-
> =C2=A0net/mac80211/util.c |=C2=A0=C2=A03 ---
> =C2=A0net/wireless/mesh.c |=C2=A0=C2=A02 +-

That's not a good patch - one change is mac80211 and the other
cfg80211.

> -	.ht_opmode =3D IEEE80211_HT_OP_MODE_PROTECTION_NONHT_MIXED,
> +	.ht_opmode =3D IEEE80211_HT_OP_MODE_PROTECTION_NONE,
>=20
How are you planning to comply with 802.11 now?


The HT Protection field in a mesh STA may be set to no protection mode
only if
=E2=80=94 All STAs detected in the primary or the secondary channel are=
 HT
=C2=A0 STAs, and
=E2=80=94 All mesh STA members of this MBSS that are one-hop neighbors =
of the
=C2=A0 transmitting mesh STA are either:
=C2=A0 =E2=80=94 20/40 MHz HT mesh STAs in a 20/40 MHz MBSS, or
=C2=A0 =E2=80=94 20 MHz HT mesh STAs in a 20 MHz MBSS.

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
