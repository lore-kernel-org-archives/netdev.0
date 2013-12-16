From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: fix TX device statistics for monitor
 interfaces
Date: Mon, 16 Dec 2013 13:38:15 +0100
Message-ID: <1387197495.4665.16.camel@jlt4.sipsolutions.net>
References: <87iowiszyu.fsf@purkki.adurom.net>
	 <1386492357-20826-1-git-send-email-pali.rohar@gmail.com>
	 (sfid-20131208_094635_923822_94E0BD99)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Gnedt <david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org>
To: Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1386492357-20826-1-git-send-email-pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (sfid-20131208_094635_923822_94E0BD99)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-12-08 at 09:45 +0100, Pali Roh=C3=A1r wrote:
> From: David Gnedt <david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org>
>=20
> Count TX packets and bytes also for monitor interfaces.

> +	dev->stats.tx_packets++;
> +	dev->stats.tx_bytes +=3D skb->len;
> +
>  	/*
>  	 * fix up the pointers accounting for the radiotap
>  	 * header still being in there.  We are being given

Should we really count the machine-local radiotap management stuff?

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
