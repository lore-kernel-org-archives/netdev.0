From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: [RFC][PATCH -mm 0/5] proposal for dynamic configurable netconsole
Date: Fri, 22 Dec 2006 21:01:09 +0900
Message-ID: <458BC905.7050003@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:38013 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964838AbWLVMB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Dec 2006 07:01:28 -0500
To: mpm@selenic.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Keiichi KII <k-keiichi@bx.jp.nec.com>

The netconsole is a very useful module for collecting kernel message under
certain circumstances(e.g. disk logging fails, serial port is unavailable).

But current netconsole is not flexible. For example, if you want to change ip
address for logging agent, in the case of built-in netconsole, you can't change
config except for changing boot parameter and rebooting your system, or in the
case of module netconsole, you need to reload netconsole module.

So, I propose the following extended features for netconsole.

1) support for multiple logging agents.
2) add interface to access each parameter of netconsole
   using sysfs.

This patch is for linux-2.6.20-rc1-mm1 and is divided to each function.
Your comments are very welcome.

Signed-off-by: Keiichi KII <k-keiichi@bx.jp.nec.com>
---
[changes]
1. change kernel base from 2.6.19 to 2.6.20-rc1-mm1.
-- 
Keiichi KII
NEC Corporation OSS Promotion Center
E-mail: k-keiichi@bx.jp.nec.com
