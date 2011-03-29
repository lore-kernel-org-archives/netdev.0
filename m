From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: zero copy for relay server
Date: Tue, 29 Mar 2011 16:13:37 +0200
Message-ID: <1301408017.3161.154.camel@edumazet-laptop>
References: <D69C90565D53114396BF743585AF5A09122E61E9E7@VSHINMSMBX01.vshodc.lntinfotech.com>
	 <1301331138.3182.43.camel@edumazet-laptop>
	 <D69C90565D53114396BF743585AF5A09122E61E9E9@VSHINMSMBX01.vshodc.lntinfotech.com>
	 <1301337257.2506.8.camel@edumazet-laptop>
	 <AANLkTimWf4kyi4HJFToXP=HH==hQgObQsHYyRfrSe0FS@mail.gmail.com>
	 <1301372590.2506.57.camel@edumazet-laptop>
	 <AANLkTi=GYxOP19HwdD0X33hX-Ku12oxwcX5=-okC9Let@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Viral Mehta <Viral.Mehta@lntinfotech.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:38702 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753463Ab1C2ONm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 10:13:42 -0400
Received: by bwz15 with SMTP id 15so206688bwz.19
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2011 07:13:41 -0700 (PDT)
In-Reply-To: <AANLkTi=GYxOP19HwdD0X33hX-Ku12oxwcX5=-okC9Let@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 29 mars 2011 =C3=A0 19:28 +0800, Changli Gao a =C3=A9crit :

> It is a waste of fd using pipe buffer with two fds. In fact, I had
> ever posted a patch, which extends pipe(2) to return a O_RDWR fd when
> NULL is passed in.
>=20

Oh well, one extra fd is less than 256 bytes.

Adding a syscall means you force users to have latest kernel.

All this is hypothetical, nobody gave performance numbers demonstrating
splice()/splice() is slow enough we have to optimize it and add kernel
bloat...



