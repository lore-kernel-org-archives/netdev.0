From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] f_phonet: avoid pskb_pull(), fix OOPS with
 CONFIG_HIGHMEM
Date: Mon, 28 Feb 2011 23:37:00 -0800 (PST)
Message-ID: <20110228.233700.71131086.davem@davemloft.net>
References: <1298465493-3787-1-git-send-email-remi.denis-courmont@nokia.com>
	<20110228.123844.70195701.davem@davemloft.net>
	<201103010934.30730.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201103010934.30730.remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: "R=E9mi Denis-Courmont" <remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date: Tue, 1 Mar 2011 09:34:30 +0200

> On Monday 28 February 2011 22:38:44 ext David Miller, you wrote:
>> From: R=E9mi Denis-Courmont <remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
>> Date: Wed, 23 Feb 2011 14:51:33 +0200
>>=20
>> > This is similar to what we already do in cdc-phonet.c in the same
>> > situation. pskb_pull() refuses to work with HIGHMEM, even if it is
>> > known that the socket buffer is entirely in "low" memory.
>> >=20
>> > Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont-xNZwKgViW5g@public.gmane.org=
m>
>>=20
>> Applied, thanks.
>=20
> Hmm, this is already somewhere in linux-usb, from what I understood (=
I suppose=20
> git-merge does not care much).

Yeah, it'll work itself out without any problems.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
