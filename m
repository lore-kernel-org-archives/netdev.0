From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] net, vxlan Fix compile warning
Date: Fri, 13 Sep 2013 14:58:14 +0200
Message-ID: <20130913125814.GA1420@minipsycho.brq.redhat.com>
References: <1379075352-20051-1-git-send-email-prarit@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jpirko@redhat.com, tgraf@redhat.com,
	"David S. Miller" <davem@davemloft.net>
To: Prarit Bhargava <prarit@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:53667 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754105Ab3IMM6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 08:58:18 -0400
Received: by mail-ea0-f175.google.com with SMTP id m14so563761eaj.34
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 05:58:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1379075352-20051-1-git-send-email-prarit@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ri, Sep 13, 2013 at 02:29:12PM CEST, prarit@redhat.com wrote:
>Fix a unintialized variable warning.
>
>drivers/net/vxlan.c: In function =E2=80=98vxlan_sock_add=E2=80=99:
>drivers/net/vxlan.c:2240:11: error: =E2=80=98sock=E2=80=99 may be used=
 uninitialized in this function [-Werror=3Dmaybe-uninitialized]
>  vs->sock =3D sock;
>           ^
>drivers/net/vxlan.c:2217:17: note: =E2=80=98sock=E2=80=99 was declared=
 here
>  struct socket *sock;
>                 ^
>
>Signed-off-by: Prarit Bhargava <prarit@redhat.com>
>Cc: jpirko@redhat.com
>Cc: tgraf@redhat.com
>Cc: "David S. Miller" <davem@davemloft.net>
Reviewed-by: Jiri Pirko <jiri@resnulli.us>
