From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: [PATCH -mm take2 0/5] proposal for dynamic configurable netconsole
Date: Tue, 26 Dec 2006 14:07:12 +0900
Message-ID: <4590AE00.5040102@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:37503 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932233AbWLZFHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Dec 2006 00:07:21 -0500
To: mpm@selenic.com
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

So, I propose the following extended features for netconsole.

1) support for multiple logging agents.
2) add interface to access each parameter of netconsole
   using sysfs.

This patch is for linux-2.6.20-rc1-mm1 and is divided to each function.
Your comments are very welcome.

Signed-off-by: Keiichi KII <k-keiichi@bx.jp.nec.com>
Signed-off-by: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
---
-- 
Keiichi KII
NEC Corporation OSS Promotion Center
E-mail: k-keiichi@bx.jp.nec.com
