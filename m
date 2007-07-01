From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 2.2LK: Low link speed after suspend
Date: Mon, 2 Jul 2007 01:02:34 +0200
Message-ID: <20070701230234.GA316@electric-eye.fr.zoreil.com>
References: <200704162241.31729.peter.missel@onlinehome.de> <20070630133810.GA15951@electric-eye.fr.zoreil.com> <20070630193003.GA21140@electric-eye.fr.zoreil.com> <200707011426.19957.peter.missel@onlinehome.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jens Stroebel <drifter@bcsoft.de>
To: Peter Missel <peter.missel@onlinehome.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50403 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751405AbXGAXET (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jul 2007 19:04:19 -0400
Content-Disposition: inline
In-Reply-To: <200707011426.19957.peter.missel@onlinehome.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Missel <peter.missel@onlinehome.de> :
[...]
> The patch applies without failure; I'm getting a warning during build=
,
>=20
>   CC [M]  drivers/net/r8169.o
> drivers/net/r8169.c: In function =E2=80=98rtl8169_start_xmit=E2=80=99=
:
> drivers/net/r8169.c:2341: warning: =E2=80=98txd=E2=80=99 may be used =
uninitialized in this=20
> function

It's known and harmless. Blame gcc :o)

--=20
Ueimor
