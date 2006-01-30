From: Luiz Fernando Capitulino <lcapitulino@mandriva.com.br>
Subject: [PATCH 0/4] - pktgen: refinements and small fixes (V2).
Date: Sun, 29 Jan 2006 23:23:42 -0200
Message-ID: <20060129232342.1e481f9a@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	robert.olsson@its.uu.se
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751217AbWA3BXn@vger.kernel.org>
To: davem <davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 Hi!

 I'm sending again the following patches for pktgen:

[PATCH 1/4]  pktgen: Lindent run.
[PATCH 2/4]  pktgen: Ports thread list to Kernel list implementation.
[PATCH 3/4]  pktgen: Fix kernel_thread() fail leak.
[PATCH 4/4]  pktgen: Fix Initialization fail leak.

 The changes from V1 are:

 1. More fixes made by hand after Lindent run
 2. Re-diffed agains't Dave's net-2.6.17 tree
 
  All the patches were tested with QEMU, emulating a machine with 4 CPUs
and 4 ethernet cards.

-- 
Luiz Fernando N. Capitulino
