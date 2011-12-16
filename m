From: Vincent Bernat <bernat@luffy.cx>
Subject: Re: nonlocal_bind and IPv6
Date: Fri, 16 Dec 2011 07:24:04 +0100
Message-ID: <m3zket9gqj.fsf@neo.luffy.cx>
References: <1323879648-419-1-git-send-email-bernat@luffy.cx>
	<CAHo-OoxrYpFMBVfriB7HhL-BpMXJgCe1-mL4L8UpsDQJifMZvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org
To: Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:33322 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751868Ab1LPGbN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 01:31:13 -0500
In-Reply-To: <CAHo-OoxrYpFMBVfriB7HhL-BpMXJgCe1-mL4L8UpsDQJifMZvQ@mail.gmail.com>
	("Maciej =?utf-8?Q?=C5=BBenczykowski=22's?= message of "Thu, 15 Dec 2011
 19:58:01 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OoO En  ce milieu  de nuit  =C3=A9toil=C3=A9e du vendredi  16 d=C3=A9ce=
mbre  2011, vers
04:58, Maciej =C5=BBenczykowski <zenczykowski@gmail.com> disait=C2=A0:

> why not simply use the IP_TRANSPARENT or IP_FREEBIND socket options?

Because  this requires  modifying each  affected software.  This  can b=
e
difficult if you don't have the source code available.
--=20
Vincent Bernat =E2=98=AF http://vincent.bernat.im

panic("Detected a card I can't drive - whoops\n");
	2.2.16 /usr/src/linux/drivers/net/daynaport.c
