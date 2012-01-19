From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: inet6_dump_fib  lock held when returning to user space
Date: Thu, 19 Jan 2012 13:33:19 +0100
Message-ID: <1326976399.2249.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <201201191148.52121.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:47389 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751075Ab2ASMdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 07:33:23 -0500
Received: by lahc1 with SMTP id c1so2877574lah.19
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2012 04:33:22 -0800 (PST)
In-Reply-To: <201201191148.52121.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 janvier 2012 =C3=A0 11:48 +0100, Hans Schillstrom a =C3=A9c=
rit :
> Hello
> Have this one been seen before ?
> It happens during a container start i.e. in a netns,
>=20
> [   19.232941] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
> [   19.268785] [ BUG: lock held when returning to user space! ]
> [   19.270146] 3.2.0+ #14 Tainted: G        W  =20
> [   19.271217] ------------------------------------------------
> [   19.272968] nsm/1042 is leaving the kernel with locks still held!
> [   19.274603] 1 lock held by nsm/1042:
> [   19.275524]  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffff8136a9b2>=
] inet6_dump_fib+0xbd/0x34a
>=20

Yep, Dave Jones reported this some days ago

"Re: recvmsg sleeping from invalid context"

I have no idea of what happens yet.
