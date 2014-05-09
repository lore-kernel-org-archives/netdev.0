From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net,stable] net: cdc_mbim: handle unaccelerated VLAN
 tagged frames
Date: Fri, 09 May 2014 13:30:39 -0400 (EDT)
Message-ID: <20140509.133039.881525971468143859.davem@davemloft.net>
References: <1399639500-13907-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1399639500-13907-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Fri,  9 May 2014 14:45:00 +0200

> This driver maps 802.1q VLANs to MBIM sessions. The mapping is based =
on
> a bogus assumption that all tagged frames will use the acceleration A=
PI
> because we enable NETIF_F_HW_VLAN_CTAG_TX. This fails for e.g. frames
> tagged in userspace using packet sockets. Such frames will erroneousl=
y
> be considered as untagged and silently dropped based on not being IP.
>=20
> Fix by falling back to looking into the ethernet header for a tag if =
no
> accelerated tag was found.
>=20
> Fixes: a82c7ce5bc5b ("net: cdc_ncm: map MBIM IPS SessionID to VLAN ID=
")
> Cc: Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

Applied, thank you!

> This bug has been present since the driver was introduced in v3.8, an=
d
> should therefore be applied to all maintained stable kernels from v3.=
8
> and onwards.  I have verified that it applies cleanly to the original
> v3.8 version as well as the current net/master, so I believe it shoul=
d
> apply unmodified all versions in between.

This annotation is very much appreciated, because when I process my
-stable queue this information in right there waiting for me in the
patchwork bundle I create.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
