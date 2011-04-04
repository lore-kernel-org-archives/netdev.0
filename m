From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: filter: Just In Time compiler
Date: Mon, 04 Apr 2011 07:21:46 +0200
Message-ID: <1301894506.2837.224.camel@edumazet-laptop>
References: <1301783301.2837.77.camel@edumazet-laptop>
	 <1301784797.3110.4.camel@localhost>
	 <1301838968.2837.200.camel@edumazet-laptop>
	 <20110403.220745.173856758.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, acme@infradead.org,
	bhutchings@solarflare.com, hagen@jauu.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64698 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544Ab1DDFV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 01:21:56 -0400
Received: by wya21 with SMTP id 21so4364678wya.19
        for <netdev@vger.kernel.org>; Sun, 03 Apr 2011 22:21:55 -0700 (PDT)
In-Reply-To: <20110403.220745.173856758.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 03 avril 2011 =C3=A0 22:07 -0700, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 03 Apr 2011 15:56:08 +0200
>=20
> >  arch/x86/Kbuild              |    1=20
> >  arch/x86/Kconfig             |    1=20
> >  arch/x86/net/bpf_jit.S       |  142 +++++++
> >  arch/x86/net/bpf_jit_comp.c  |  655 ++++++++++++++++++++++++++++++=
+++
>=20
> Is this missing arch/x86/net/Makefile?
>=20
> Otherwise I can't see how the x86 bpf objects get built.

Arg yes, sorry, I'll add it for V3 ;)

diff --git a/arch/x86/net/Makefile b/arch/x86/net/Makefile
new file mode 100644
index 0000000..53b46d1
--- /dev/null
+++ b/arch/x86/net/Makefile
@@ -0,0 +1,5 @@
+#
+# Arch-specific network modules
+#
+obj-$(CONFIG_BPF_JIT) +=3D bpf_jit.o bpf_jit_comp.o
+


