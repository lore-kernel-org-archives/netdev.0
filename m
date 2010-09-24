From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/5] AF_UNIX: enable/disable multicast with
 getsockopt/setsockopt
Date: Fri, 24 Sep 2010 19:46:28 +0200
Message-ID: <1285350388.2478.0.camel@edumazet-laptop>
References: <20100924182257.11abd9a6@chocolatine.cbg.collabora.co.uk>
	 <1285349116-17529-2-git-send-email-alban.crequy@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Ian Molton <ian.molton@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dbus@freedesktop.org
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54768 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754587Ab0IXRqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 13:46:47 -0400
In-Reply-To: <1285349116-17529-2-git-send-email-alban.crequy@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 24 septembre 2010 =C3=A0 18:25 +0100, Alban Crequy a =C3=A9=
crit :
> Multicast can be enabled or disabled after a socket is allocated but =
this
> cannot be changed once the socket is bound or connected.
>=20
> Userspace applications can enable multicast on an Unix stream socket:
>   sockfd =3D socket(AF_UNIX, SOCK_STREAM, 0);
>   #define UNIX_MULTICAST 1
>   val =3D 1;
>   len =3D sizeof(val);
>   ret =3D setsockopt(sockfd, 0, UNIX_MULTICAST, &val, len);
>=20
> Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>


> +		if (val !=3D 0) {
> +			u->multicast =3D 1;
> +		} else {
> +			u->multicast =3D 0;
> +		}

u->multicast =3D !!val;



