From: Sean Neakums <sneakums@zork.net>
Subject: 2.6.9-rc1-mm4: r8169: irq 16: nobody cared!/TX Timeout
Date: Sun, 12 Sep 2004 00:16:43 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <6upt4s4cro.fsf@zork.zork.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, akpm@osdl.org, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268356AbUIKXQ7@vger.kernel.org>
To: romieu@fr.zoreil.com
List-Id: netdev.vger.kernel.org

irq 16: nobody cared!
 [<c0106864>] __report_bad_irq+0x24/0x90
 [<c0106ad2>] note_interrupt+0x92/0x160
 [<c0106f12>] do_IRQ+0x162/0x1a0
 [<c010491c>] common_interrupt+0x18/0x20
 [<c0101f80>] default_idle+0x0/0x40
 [<c0101fac>] default_idle+0x2c/0x40
 [<c0102034>] cpu_idle+0x34/0x50
handlers:
[<c02a5470>] (rtl8169_interrupt+0x0/0x1d0)
Disabling IRQ #16
NETDEV WATCHDOG: eth2: transmit timed out
eth2: TX Timeout

CONFIG_R8169_NAPI=y

I downed and upped the interface and it started working again.
