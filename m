From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [DESC 2.6.8.1-mm4] r8169 patches
Date: Tue, 24 Aug 2004 00:41:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040823224100.GA14680@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here comes a new serie of r8169 related patches which should allow
the motivated users to experiment new features, namely:
- Rx/Tx checksum offload;
- vlan support;
- better ethtool integration.

Tx code apart, the changes exhibit some strong similarity with the
8139cp driver.

I have not done vlan-dedicated test and there are no figures to highlight
any performance improvement. The code does not crash in a (really slow)
debug enabled -mm kernel and it does not seem to add huge leak.

Remarks/comments/test reports welcome.

--
Ueimor
