From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: filter: Just In Time compiler
Date: Thu, 14 Apr 2011 17:45:51 +0200
Message-ID: <1302795951.3248.14.camel@edumazet-laptop>
References: <1301783301.2837.77.camel@edumazet-laptop>
	 <1301784797.3110.4.camel@localhost>
	 <1301838968.2837.200.camel@edumazet-laptop> <4DA70743.1050106@redhat.com>
	 <0a7fdea6b816da546ea71f752d36b5c2@localhost>  <4DA715BB.6050307@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60821 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758856Ab1DNPpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 11:45:55 -0400
Received: by wya21 with SMTP id 21so1518198wya.19
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2011 08:45:54 -0700 (PDT)
In-Reply-To: <4DA715BB.6050307@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 14 avril 2011 =C3=A0 18:41 +0300, Avi Kivity a =C3=A9crit :

> I'm talking about optimizing the generated code.  For example, bpf ha=
s=20
> just two registers so a complex program generates a lot of loads and=20
> stores.  An optimizing compiler can use extra target registers to avo=
id=20
> those spills, and doesn't need to keep A and X in fixed registers.
>=20

Thats not exactly true.

A bpf filter also uses up to 16 mem[] 'registers'.

A risc cpu (with a lot of registers) could use registers to hold part o=
f
the mem[] array.

> If you translate the bpf program to C and optimize that with gcc you'=
ll=20
> probably get much better machine code that the jit in the patch.
>=20

Well, gcc wont optimize a lot a bpf program if you ask me.

You would better make tcpdump not generate bpf but direct C code.




