From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: [PATCH 2/2] myri10ge: use ioremap_wc
Date: Sun, 10 Aug 2008 14:25:01 +0300
Message-ID: <20080810112500.GA8060@deprecation.cyrius.com>
References: <488447E7.2060505@myri.com> <48844831.9040102@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:3135 "EHLO sorrow.cyrius.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752931AbYHJL2U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Aug 2008 07:28:20 -0400
Content-Disposition: inline
In-Reply-To: <48844831.9040102@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Brice Goglin <brice@myri.com> [2008-07-21 10:26]:
> Switch to ioremap_wc(). We keep the MTRR code since ioremap_wc()
> will use UC_MINUS when falling back to uncachable, and thus let
> the MTRR WC take precedence.

This change leads to a compilation failure on (at least) arm:

  CC [M]  drivers/net/myri10ge/myri10ge.o
drivers/net/myri10ge/myri10ge.c: In function =E2=80=98myri10ge_probe=E2=
=80=99:
drivers/net/myri10ge/myri10ge.c:3725: error: implicit declaration of fu=
nction =E2=80=98ioremap_wc=E2=80=99
drivers/net/myri10ge/myri10ge.c:3725: warning: assignment makes pointer=
 from integer without a cast
make[3]: *** [drivers/net/myri10ge/myri10ge.o] Error 1

--=20
Martin Michlmayr
http://www.cyrius.com/
