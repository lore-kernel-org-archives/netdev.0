From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [uclinux-dist-devel] [PATCH net-next-2.6] netdev: bfin_mac: Use
 is_multicast_ether_addr helper
Date: Wed, 12 Jan 2011 11:38:03 -0500
Message-ID: <AANLkTimztPZB3N+ZYNsDM9L3ZEM+x__bBc-JCRgO8iDC@mail.gmail.com>
References: <1294824611-10483-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Hennerich <michael.hennerich@analog.com>,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f194.google.com ([74.125.82.194]:58859 "EHLO
	mail-wy0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200Ab1ALQqr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 11:46:47 -0500
Received: by wyf23 with SMTP id 23so248784wyf.1
        for <netdev@vger.kernel.org>; Wed, 12 Jan 2011 08:46:45 -0800 (PST)
In-Reply-To: <1294824611-10483-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 12, 2011 at 04:30, Tobias Klauser wrote:
> --- a/drivers/net/bfin_mac.c
> +++ b/drivers/net/bfin_mac.c
> @@ -1293,7 +1293,7 @@ static void bfin_mac_multicast_hash(struct net_=
device *dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0addrs =3D ha->=
addr;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* skip non-mu=
lticast addresses */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!(*addrs & 1))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!is_multicast_=
ether_addr(addrs))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0continue;

looks good to me ...
Acked-by: Mike Frysinger <vapier@gentoo.org>
-mike
