From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: [RFC][PATCH -mm take4 0/6] proposal for dynamic configurable netconsole
Date: Wed, 18 Apr 2007 20:49:48 +0900
Message-ID: <462605DC.2080804@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel-owner@vger.kernel.org,
	netdev@vger.kernel.org
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:61733 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422887AbXDRLuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 07:50:18 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Keiichi KII <k-keiichi@bx.jp.nec.com>

The netconsole is a very useful module for collecting kernel message under
certain circumstances(e.g. disk logging fails, serial port is unavailable).

But current netconsole is not flexible. For example, if you want to change ip
address for logging agent, in the case of built-in netconsole, you can't change
config except for changing boot parameter and rebooting your system, or in the
case of module netconsole, you need to remove it and reload with different
parameters.

By adopting my patches, the current netconsole becomes a little complex.
But the kernel messages(especially panic messages) is significant information
 to solve bugs and troubles promptly and we have been losing serial console
port with PCs and Servers.

I think that we need the environment in which we can collect kernel messages
flexibly.

So, I propose the following extended features for netconsole.

1) support for multiple logging agents.
2) add interface to access each parameter of netconsole
   using sysfs.

[changes since take3]
-changing kernel base from 2.6.21-rc3-mm2 to 2.6.21-rc6-mm1.
-introducing CONFIG_NETCONSOLE_DYNCON.
-cleanup

Your comments are very welcome.

Signed-off-by: Keiichi KII <k-keiichi@bx.jp.nec.com>
Signed-off-by: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
---

