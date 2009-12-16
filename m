From: Zhiyong Wu <zwu.kernel@gmail.com>
Subject: Re: net-2.6 build error on powerpc
Date: Wed, 16 Dec 2009 16:37:44 +0800
Message-ID: <b1e768440912160037v21cf7ed2s521c0ac1307c583e@mail.gmail.com>
References: <20091008152044.GA15390@linux-ox1b.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, davem@davemloft.net,
	Herbert Xu <herbert@gondor.apana.org.au>, llim@redhat.com,
	Zhiyong Wu <zwu.kernel@gmail.com>, Avi Kivity <avi@redhat.com>,
	agraf@suse.de,
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.216.174]:56629 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288AbZLPIhp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 03:37:45 -0500
Received: by pxi4 with SMTP id 4so557454pxi.33
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 00:37:44 -0800 (PST)
In-Reply-To: <20091008152044.GA15390@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HI, Ron Mercer

In order to succeed in compiling, currently i comment out the line
that includes the option "Werror" in the file Makefile.

Similiar to :

diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefil=
e
index b23664a..0c8a8b0 100644
--- a/arch/powerpc/kernel/Makefile
+++ b/arch/powerpc/kernel/Makefile
@@ -4,7 +4,7 @@

 CFLAGS_ptrace.o                +=3D -DUTS_MACHINE=3D'"$(UTS_MACHINE)"'

-subdir-ccflags-$(CONFIG_PPC_WERROR) :=3D -Werror
+#subdir-ccflags-$(CONFIG_PPC_WERROR) :=3D -Werror

 ifeq ($(CONFIG_PPC64),y)
 CFLAGS_prom_init.o     +=3D -mno-minimal-toc

Can anyone let me know how to fix this issue thoroughly?


Cheers,

Zhiyong Wu


On Thu, Oct 8, 2009 at 11:20 PM, Ron Mercer <ron.mercer@qlogic.com> wro=
te:
> I recently grabbed the latest net-2.6 kernel for a powerpc test box a=
nd
> got this compile error.
>
> =C2=A0CC =C2=A0 =C2=A0 =C2=A0arch/powerpc/kernel/cputable.o
> =C2=A0CC =C2=A0 =C2=A0 =C2=A0arch/powerpc/kernel/ptrace.o
> =C2=A0CC =C2=A0 =C2=A0 =C2=A0arch/powerpc/kernel/syscalls.o
> =C2=A0CC =C2=A0 =C2=A0 =C2=A0arch/powerpc/kernel/irq.o
> =C2=A0CC =C2=A0 =C2=A0 =C2=A0arch/powerpc/kernel/align.o
> =C2=A0CC =C2=A0 =C2=A0 =C2=A0arch/powerpc/kernel/signal_32.o
> =C2=A0CC =C2=A0 =C2=A0 =C2=A0arch/powerpc/kernel/pmc.o
> =C2=A0CC =C2=A0 =C2=A0 =C2=A0arch/powerpc/kernel/vdso.o
> =C2=A0cc1: warnings being treated as errors
> =C2=A0arch/powerpc/kernel/vdso.c:78: warning: alignment of
> =C2=A0=C4=81so_data_store=C4=81s greater than maximum object file
> =C2=A0alignment. =C2=A0Using 32768
> =C2=A0make[1]: *** [arch/powerpc/kernel/vdso.o] Error 1
> =C2=A0make: *** [arch/powerpc/kernel] Error 2
> =C2=A0[root@localhost linux-2.6-net.git]#
>
>
>
> =C2=A0Any suggestions would be appreciated.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>
