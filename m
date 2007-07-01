From: Peter Missel <peter.missel@onlinehome.de>
Subject: Re: r8169 2.2LK: Low link speed after suspend
Date: Sun, 1 Jul 2007 14:26:19 +0200
Message-ID: <200707011426.19957.peter.missel@onlinehome.de>
References: <200704162241.31729.peter.missel@onlinehome.de> <20070630133810.GA15951@electric-eye.fr.zoreil.com> <20070630193003.GA21140@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jens Stroebel <drifter@bcsoft.de>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:54665 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715AbXGANpg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2007 09:45:36 -0400
In-Reply-To: <20070630193003.GA21140@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bonjour Francois!

> If you feel adventurous, you will find a compile-tested-only patchkit=
 for
> 2.6.21.5 here:
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.21.5
> or:
> http://www.fr.zoreil.com/people/francois/misc/20060630-2.6.21.5-r8169=
-test.
>patch
>
> The content should be almost the same as the 2.6.22-rc6 patchkit date=
d
> from 2007/06/28 (i.e. pending 2.6.23 merge).
>

Many thanks!

The patch applies without failure; I'm getting a warning during build,

  CC [M]  drivers/net/r8169.o
drivers/net/r8169.c: In function =E2=80=98rtl8169_start_xmit=E2=80=99:
drivers/net/r8169.c:2341: warning: =E2=80=98txd=E2=80=99 may be used un=
initialized in this=20
function

After installing and loading the new driver, I still do have a gigabit=20
connection, which is good. I'll be reporting about the suspend/resume=20
behaviour next.

regards,
Peter
