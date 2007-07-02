From: Peter Missel <peter.missel@onlinehome.de>
Subject: Re: r8169 2.2LK: Low link speed after suspend
Date: Mon, 2 Jul 2007 22:07:00 +0200
Message-ID: <200707022207.01132.peter.missel@onlinehome.de>
References: <200704162241.31729.peter.missel@onlinehome.de> <200707011426.19957.peter.missel@onlinehome.de> <20070701230234.GA316@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jens Stroebel <drifter@bcsoft.de>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:57310 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753102AbXGBUHM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 16:07:12 -0400
In-Reply-To: <20070701230234.GA316@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Francois.

Unfortunately I couldn't get NFS to work with the updated kernel, so I =
had to=20
revert to the original from SuSE 10.2.

The other thing that didn't work with 2.6.21.5 was suspend-to-disk (wou=
ld=20
suspend, but not resume), so I don't have any useful input for you this=
 time.

I'll be back.

regards,
Peter


> Peter Missel <peter.missel@onlinehome.de> :
> [...]
>
> > The patch applies without failure; I'm getting a warning during bui=
ld,
> >
> >   CC [M]  drivers/net/r8169.o
> > drivers/net/r8169.c: In function =E2=80=98rtl8169_start_xmit=E2=80=99=
:
> > drivers/net/r8169.c:2341: warning: =E2=80=98txd=E2=80=99 may be use=
d uninitialized in
> > this function
>
> It's known and harmless. Blame gcc :o)


