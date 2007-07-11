From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: Re: [RFC][PATCH v2 -mm 0/9] netconsole: Multiple targets and dynamic
 reconfigurability
Date: Wed, 11 Jul 2007 18:59:32 +0900
Message-ID: <4694AA04.1000202@bx.jp.nec.com>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Matt Mackall <mpm@selenic.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:57494 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762716AbXGKKCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 06:02:38 -0400
In-Reply-To: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Satyam,

I'm going to test/review these patches and report the result of tests 
on IA64/x86 until this Friday.

> [0/9] netconsole: Multiple targets and dynamic reconfigurability
> 
> This patchset is a rework of the original idea and patches posted by
> Keiichi Kii and Takayoshi Kochi at: http://lkml.org/lkml/2007/6/13/72
> 
> This is v2 of the patchset, the previous version is available at:
> http://lkml.org/lkml/2007/7/4/107
> 
> This is diffed against 2.6.22-rc6-mm1 + the earlier netpoll fixlet and the
> configfs cleanup patches (those are already merged in -mm AFAIK, and hence
> not reproduced here).
> 
> [1/9] netconsole: Cleanups, codingstyle, prettyfication
> [2/9] netconsole: Remove bogus check
> [3/9] netconsole: Simplify boot/module option setup logic
> [4/9] netconsole: Add some useful tips to documentation
> [5/9] netconsole: Introduce netconsole_target
> [6/9] netconsole: Introduce netconsole_netdev_notifier
> [7/9] netconsole: Use netif_running() in write_msg()
> [8/9] netconsole: Support multiple logging targets
> [9/9] netconsole: Support dynamic reconfiguration using configfs

Thanks
-- 
Keiichi KII
NEC Corporation OSS Platform Development Division
E-mail: k-keiichi@bx.jp.nec.com
