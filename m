From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [DESC 2.6.8.1-mm4] 8139too patches
Date: Sun, 22 Aug 2004 23:39:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040822213954.GA29997@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

As Jeff pointed out, there was a flaw in the 8139too patches that I have
submitted earlier. They are included in -mm as:
8139too-rx-fifo-overflow-recovery.patch
  8139too: Rx fifo/overflow recovery

8139too-be-sure-to-progress-durin-rtl8139_rx.patch
  8139too: be sure to progress durin rtl8139_rx()

The initial issue which led to these patch was reported by Pasi Sjoholm
on l-k/netdev. The brokenness that Jeff outlined was actually reported
by Jurriaan later.

Both have confirmed that the new version of the 8139too patches fix
the original issue where it appeared and does not introduce new pesky
behavior.

Please replace the two patches with the two following ones.

--
Ueimor
