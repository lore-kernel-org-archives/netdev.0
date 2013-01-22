From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH net] net: cdc_ncm: workaround for missing CDC Union
Date: Tue, 22 Jan 2013 09:50:39 +0100
Message-ID: <6132136.Whp52cipJH@linux-5eaq.site>
References: <1358519147-10073-1-git-send-email-bjorn@mork.no> <2214944.HMNV73jJm5@linux-5eaq.site> <87ip6qy2q7.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87ip6qy2q7.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 21 January 2013 16:28:48 Bj=F8rn Mork wrote:

> Agreed.  But I believe the condition should be=20
>=20
>  if (!(info->flags & FLAG_SEND_ZLP) && !(info->flags & FLAG_MULTI_PAC=
KET)) {
>      ..
>  } else {
>      urb->transfer_flags |=3D URB_ZERO_PACKET;
>  }
>=20
> to ensure that we send the ZLP in this case.

Why? If a driver wants ZLP, it can set FLAG_SEND_ZLP. Your proposed cha=
nge
would take away an option from drivers without any gain.

> > Besides you may want the current behavior.
>=20
> Why? Does it ever make sense to prevent both the short packet and the
> ZLP?

Why not? It is possible and a driver may want it, so why forbid it?
Especially, as in theory it takes least bandwidth as a solution.

	Regards
		Oliver


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
