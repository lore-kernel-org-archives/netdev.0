From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/5] netlink: store MSG_CMSG_COMPAT flag in
 netlink_skb_parms
Date: Thu, 18 Feb 2010 08:37:14 +0100
Message-ID: <1266478634.3807.1.camel@jlt3.sipsolutions.net>
References: <1266252393-20911-1-git-send-email-fw@strlen.de>
	 <1266252393-20911-3-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-f80PWwrSl+f/PApjHKt9"
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:33476 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323Ab0BRHhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 02:37:19 -0500
In-Reply-To: <1266252393-20911-3-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-f80PWwrSl+f/PApjHKt9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2010-02-15 at 17:46 +0100, Florian Westphal wrote:
> This allows the netlink processing context to determine if the data
> needs any 32 bit fixups.

> --- a/include/linux/netlink.h
> +++ b/include/linux/netlink.h
> @@ -164,6 +164,7 @@ struct netlink_skb_parms {
>  	__u32			loginuid;	/* Login (audit) uid */
>  	__u32			sessionid;	/* Session id (audit) */
>  	__u32			sid;		/* SELinux security id */
> +	__u8			msg_compat;	/* Message needs 32bit fixups */

bool?

johannes

--=-f80PWwrSl+f/PApjHKt9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLfO4mAAoJEODzc/N7+QmamgsQAMfrmXXulAklc7lVn0bVSP/j
6DE/gdhEvK0UKLYgAqTzyUBIGEV+J+sbrXhGFTxVWaG0QUHB3KUxRSuDW1jDHdFq
ywUPt5kjf6c376dp2ndWIQfFYLQNoFSQWi3HfECs4htZTI+mwEzM0hjyeL6TI1ck
qHrszhK/MJDA4yjgsFO6UrNWYfaXR9PBSwXUKSAOAqKhYLCuSM+iR1ew4zNAfOGQ
GPyZVNGO2ZgdjR3SY2l5IHGj9MpYkEetwXGhwFBxZ5+1KKjC1cA/03xL0pQtYd36
KjnbW+GOHOlMdBYfbeoNAJ14n35cpLL6wyqtkbEwgKIzrE0tSnF+887D/TaMpTnz
mrKbg604f1h3qDLuDn3kNziN7Heg37xrws8hjSVS1eX9s+m+ShuUugCSFGbEjBR8
gouNTIWOcjMz9sE1ALV8Z3EW+GQdXF6KQ8kc1DI0TS1ZEi1o7gy+ChL9zzha7Giw
NUh23uL3e/I8kFLaqazBogYxPKueUky0VIbbVOqtXR34nP8kMJASt+IxeAkofzdR
8AYl0bCze0B4s9b4LUpwo0bcj6v6qMTZxD3Cnm/rbF1LALYqyVnm2EAraofCw+Fl
0/GCPJl3dQn3sWrhZton2EvMKvkiyDw33UUbWOIhf6taEWIVmROxj/al9VrJ7ZNE
BaImr2pTdKLkn1Bgj6cw
=VM3p
-----END PGP SIGNATURE-----

--=-f80PWwrSl+f/PApjHKt9--

