From: Pekka Enberg <penberg@kernel.org>
Subject: [PROBLEM] WARNING: at kernel/exit.c:910 do_exit
Date: Sun, 21 Nov 2010 17:35:01 +0200
Message-ID: <AANLkTi=ej5guZ2R72=fqe5mciwjVeY5LkDL3Qx1W0GvA__35186.7714700804$1290353743$gmane$org@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: oleg@redhat.com, Linus Torvalds <torvalds@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:35060 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754031Ab0KUPfC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Nov 2010 10:35:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

The following warning triggered on me while I was browsing the web:

  http://twitpic.com/38vxxg

[ Click on the "Rotate photo" button for landscape version.=A0]

It's

        WARN_ON(atomic_read(&tsk->fs_excl));

in do_exit(). There was a prior oops in __pipe_free_info() called in
sys_recvmsg() paths that unfortunately scrolled away. Does it ring a
bell to anyone? This is latest Linus' master from few hours ago. I've
been running 2.6.37-rc1 until today without any problems.

I'll let you know if it triggers again.

                        Pekka
