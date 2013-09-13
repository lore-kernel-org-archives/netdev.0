From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net, vxlan Fix compile warning
Date: Fri, 13 Sep 2013 07:20:28 -0700
Message-ID: <20130913072028.54b1c28d@samsung-9>
References: <1379075352-20051-1-git-send-email-prarit@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jpirko@redhat.com, tgraf@redhat.com,
	"David S. Miller" <davem@davemloft.net>
To: Prarit Bhargava <prarit@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:61844 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754897Ab3IMOUc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 10:20:32 -0400
Received: by mail-pd0-f176.google.com with SMTP id q10so1298924pdj.7
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 07:20:32 -0700 (PDT)
In-Reply-To: <1379075352-20051-1-git-send-email-prarit@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Sep 2013 08:29:12 -0400
Prarit Bhargava <prarit@redhat.com> wrote:

> Fix a unintialized variable warning.
>=20
> drivers/net/vxlan.c: In function =E2=80=98vxlan_sock_add=E2=80=99:
> drivers/net/vxlan.c:2240:11: error: =E2=80=98sock=E2=80=99 may be use=
d uninitialized in this function [-Werror=3Dmaybe-uninitialized]
>   vs->sock =3D sock;
>            ^
> drivers/net/vxlan.c:2217:17: note: =E2=80=98sock=E2=80=99 was declare=
d here
>   struct socket *sock;
>                  ^
>=20
> Signed-off-by: Prarit Bhargava <prarit@redhat.com>
> Cc: jpirko@redhat.com
> Cc: tgraf@redhat.com
> Cc: "David S. Miller" <davem@davemloft.net>

Which compiler version? Gcc 4.6 is known to be stupid,
and I would rather not change the source if it is only caused
by a gcc bug fixed in a later release.
