From: KII Keiichi <k-keiichi@bx.jp.nec.com>
Subject: Re: [PATCH v2 -mm 7/9] netconsole: Use netif_running() in write_msg()
Date: Fri, 13 Jul 2007 22:48:09 +0900
Message-ID: <46978299.7040908@bx.jp.nec.com>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in> <20070710091956.23907.61655.sendpatchset@cselinux1.cse.iitk.ac.in>
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
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:58554 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759540AbXGMNsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 09:48:07 -0400
In-Reply-To: <20070710091956.23907.61655.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Satyam,

> From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> 
> [7/9] netconsole: Use netif_running() in write_msg()
> 
> Avoid unnecessarily disabling interrupts and calling netpoll_send_udp()
> if the corresponding local interface is not up.
> 
> Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>
> 
Acked-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>

Thanks
--
Keiichi KII
NEC Corporation OSS Platform Development Division
E-mail: k-keiichi@bx.jp.nec.com

