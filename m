From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [PATCH] net: ping: cleanups ping_v4_unhash()
Date: Mon, 23 May 2011 12:43:08 +0400
Message-ID: <20110523084308.GA6244@albatros>
References: <1306138981.2869.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:36058 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257Ab1EWInN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 04:43:13 -0400
Received: by bwz15 with SMTP id 15so4512906bwz.19
        for <netdev@vger.kernel.org>; Mon, 23 May 2011 01:43:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1306138981.2869.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 23, 2011 at 10:23 +0200, Eric Dumazet wrote:
> net/ipv4/ping.c: In function =E2=80=98ping_v4_unhash=E2=80=99:
> net/ipv4/ping.c:140:28: warning: variable =E2=80=98hslot=E2=80=99 set=
 but not used
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Vasiliy Kulikov <segoon@openwall.com>

hslot was used for debugging purposes here.


BTW, what gcc version do you use?  I have no warning with 4.4.3
(Ubuntu 4.4.3-4ubuntu5):

    $ make net/ipv4/ping.o
      CHK     include/linux/version.h
      CHK     include/generated/utsrelease.h
      CALL    scripts/checksyscalls.sh
      CC      net/ipv4/ping.o
    $


Thanks,

--=20
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environ=
ments
