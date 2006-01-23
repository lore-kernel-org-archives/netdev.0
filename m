From: Luiz Fernando Capitulino <lcapitulino@mandriva.com.br>
Subject: [PATCH 00/00] pktgen: refinements and small fixes.
Date: Mon, 23 Jan 2006 13:41:40 -0200
Message-ID: <20060123134140.b04ad994.lcapitulino@mandriva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	robert.olsson@its.uu.se
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932459AbWAWQO0@vger.kernel.org>
To: davem <davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 Hi!

 I have the following patches for pktgen:

 [PATCH 00/01] pktgen: Lindent run.
 [PATCH 00/02] pktgen: Ports thread list to Kernel list implementation.
 [PATCH 00/03] pktgen: Fix kernel_thread() fail leak.
 [PATCH 00/04] pktgen: Fix Initialization fail leak. 

 All the patches were tested with QEMU, emulating a machine with 4 CPUs
and 4 ethernet cards.

 There is more work I'd like to do for pktgen, it includes:

 1. pg_cleanup() should freed the memory of the tasks it just terminated
 (there's a leak there I think)
 2. Port the interface list to the kernel linked list implementation
 3. Review pktgen's debug printk()s

 But I'm sending these patches first, just to know if I'm doing something
wrong.

 Thank you

-- 
Luiz Fernando N. Capitulino
