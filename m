From: Ron Mercer <ron.mercer@qlogic.com>
Subject: net-2.6 build error on powerpc
Date: Thu, 8 Oct 2009 08:20:44 -0700
Message-ID: <20091008152044.GA15390@linux-ox1b.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ron.mercer@qlogic.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:24153 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758489AbZJHP1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 11:27:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I recently grabbed the latest net-2.6 kernel for a powerpc test box and
got this compile error.

  CC      arch/powerpc/kernel/cputable.o
  CC      arch/powerpc/kernel/ptrace.o
  CC      arch/powerpc/kernel/syscalls.o
  CC      arch/powerpc/kernel/irq.o
  CC      arch/powerpc/kernel/align.o
  CC      arch/powerpc/kernel/signal_32.o
  CC      arch/powerpc/kernel/pmc.o
  CC      arch/powerpc/kernel/vdso.o
  cc1: warnings being treated as errors
  arch/powerpc/kernel/vdso.c:78: warning: alignment of
  =E2so_data_store=E2s greater than maximum object file
  alignment.  Using 32768
  make[1]: *** [arch/powerpc/kernel/vdso.o] Error 1
  make: *** [arch/powerpc/kernel] Error 2
  [root@localhost linux-2.6-net.git]#



  Any suggestions would be appreciated.

