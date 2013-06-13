From: Tommi Rantala <tt.rantala@gmail.com>
Subject: =?windows-1252?B?aW5jbHVkZS9uZXQvaXB2Ni5oOjQwODozODogd2FybmluZzogkSooKHZvaWQgKikmYWQ=?=
	=?windows-1252?B?ZHIrOCmSIG1heSBiZSB1c2VkIHVuaW5pdGlhbGl6ZWQgaW4gdGhpcyBmdW5jdGlvbg==?=
Date: Thu, 13 Jun 2013 18:16:19 +0300
Message-ID: <CA+ydwtrVHDE65dVTBijGguZDK0+=+tzi+nn1UywRqfn9Rx4ZuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, I'm seeing the following compiler warnings. Do these make any
sense? I'm doing a x86-64 build.

/build/linux/net/ipv4/tcp_metrics.c: In function =91tcp_peer_is_proven=92=
:
/build/linux/include/net/ipv6.h:408:38: warning: =91*((void *)&addr+8)=92
may be used uninitialized in this function [-Wmaybe-uninitialized]
/build/linux/net/ipv4/tcp_metrics.c:211:23: note: =91*((void *)&addr+8)=
=92
was declared here
In file included from /build/linux/include/net/inetpeer.h:15:0,
                 from /build/linux/net/ipv4/tcp_metrics.c:16:
/build/linux/net/ipv4/tcp_metrics.c: In function =91tcp_tw_remember_sta=
mp=92:
/build/linux/include/net/ipv6.h:408:38: warning: =91*((void *)&addr+8)=92
may be used uninitialized in this function [-Wmaybe-uninitialized]
/build/linux/net/ipv4/tcp_metrics.c:245:23: note: =91*((void *)&addr+8)=
=92
was declared here

$ gcc --version
gcc (Ubuntu/Linaro 4.7.3-1ubuntu1) 4.7.3
Copyright (C) 2012 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is=
 NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURP=
OSE.

config:
http://fpaste.org/18443/13711363/

Tommi
