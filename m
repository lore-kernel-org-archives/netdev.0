From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [RFC]: vlan priority handling in WMM
Date: Thu, 11 Jul 2013 18:17:10 +0100
Message-ID: <1373563030.2085.14.camel@bwh-desktop.uk.level5networks.com>
References: <773DB8A82AB6A046AE0195C68612A319015E05AD@sbs2003.acksys.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Cedric Debarge <cedric.debarge-eYuUwLwYA0BQFI55V6+gNQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <773DB8A82AB6A046AE0195C68612A319015E05AD-qlrpn221Ff23xYJzE/SBhoT4S9po1h25@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-07-11 at 09:45 +0200, Cedric Debarge wrote:
> Dear mailing list,
>=20
> I would like to manage the VLAN priority in Wireless QOS (WMM).
>=20
> I get the VLAN tag from skb->vlan_tci and I extract the VLAN priority=
=2E=20
>=20
> How I should handle the priority value 0.=20
> 	- Handle this value as no priority request, In this case the frame w=
ill=20
> 		sent with the DSCP priority or default (Best effort)
>         - Handle this value as a lowest priority, in this case I Map =
it to the WMM.
[...]

IEEE 802.1q refers to the definition in 802.1d:

> The user_priority parameter is the priority requested by the
> originating service user. The value of this parameter is in the range
> 0 through 7.
>=20
> NOTE=E2=80=94The default user_priority value is 0. Values 1 through 7=
 form an
> ordered sequence of user_priorities, with 1 being the lowest value an=
d
> 7 the highest. See 7.7.3 and Annex G (informative) for further
> explanation of the use of user_priority values.

So a value of 0 should be treated as no priority request, same as for a=
n
untagged frame.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
