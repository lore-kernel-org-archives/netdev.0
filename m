From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [net-2.6 PATCH] af_packet: move strict addr_len check right
 before dev_[mc/unicast]_[add/del]
Date: Wed, 03 Mar 2010 07:57:39 +0100
Message-ID: <1267599459.2839.91.camel@edumazet-laptop>
References: <1267578048.14049.11.camel@mj>
	 <20100303064001.GB2648@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tcpdump-workers-YE1jQ5a0g24KACXWX4p+q9i2O/JbrIOy@public.gmane.org,
	proski-mXXj517/zsQ@public.gmane.org
To: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100303064001.GB2648-YzwxZg+R7et1/kRsl7OVgNvLeJWuRmrY@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le mercredi 03 mars 2010 =C3=A0 07:40 +0100, Jiri Pirko a =C3=A9crit :
> Subject: [net-2.6 PATCH] af_packet: move strict addr_len check right =
before dev_[mc/unicast]_[add/del]
>=20
> My previous patch 914c8ad2d18b62ad1420f518c0cab0b0b90ab308 incorrectl=
y changed
> the length check in packet_mc_add to be more strict. The problem is t=
hat
> userspace is not filling this field (and it stays zeroed) in case of =
setting
> PACKET_MR_PROMISC or PACKET_MR_ALLMULTI. So move the strict check to =
the point
> in path where the addr_len must be set correctly.
>=20
> Signed-off-by: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>=20

I am not sure it solves Pavel Roskin concern, but some credit should be
given to him :)

Reported-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

Thanks


--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
