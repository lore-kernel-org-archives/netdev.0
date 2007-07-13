From: KII Keiichi <k-keiichi@bx.jp.nec.com>
Subject: Re: [PATCH v2 -mm 8/9] netconsole: Support multiple logging targets
Date: Fri, 13 Jul 2007 22:49:27 +0900
Message-ID: <469782E7.1070302@bx.jp.nec.com>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in> <20070710092001.23907.39876.sendpatchset@cselinux1.cse.iitk.ac.in>
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
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:59003 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755249AbXGMNtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 09:49:24 -0400
In-Reply-To: <20070710092001.23907.39876.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Satyam,

> From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> 
> [8/9] netconsole: Support multiple logging targets
> 
> This patch introduces support for multiple targets:
> 
> Let's keep this out of CONFIG_NETCONSOLE_DYNAMIC as well -- this is useful
> even in the default case and (including the infrastructure introduced in
> previous patches) doesn't really add too many bytes to module text. All the
> complexity (and size) comes with the dynamic reconfigurability / userspace
> interface patch, and so it's plausible users may want to keep this enabled
> but that disabled (say to avoid a dep on CONFIG_CONFIGFS_FS too).
> 
> Also update documentation to mention the use of ";" separator to specify
> multiple logging targets in the boot/module option string.
> 
> Brief overview:
> 
> We maintain a target_list (and corresponding lock). Get rid of the static
> "default_target" and introduce allocation and release functions for our
> netconsole_target objects (but keeping sure to preserve previous behaviour
> such as default values). During init_netconsole(), ";" is used as the
> separator to identify multiple target specifications in the boot/module
> option string. The target specifications are parsed and netpolls setup.
> During exit, the target_list is torn down and all items released.
> 
> Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>
> 
Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>

Thanks
--
Keiichi KII
NEC Corporation OSS Platform Development Division
E-mail: k-keiichi@bx.jp.nec.com


