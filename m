From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for April 7 (net/core/dev_addr_lists)
Date: Wed, 7 Apr 2010 09:58:45 -0700
Message-ID: <20100407095845.f29ebf48.randy.dunlap@oracle.com>
References: <20100407174123.81b32310.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:37501 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932873Ab0DGROb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 13:14:31 -0400
In-Reply-To: <20100407174123.81b32310.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 Apr 2010 17:41:23 +1000 Stephen Rothwell wrote:

> Hi all,
> 
> Changes since 20100401:


when CONFIG_PROC_FS is disabled:

linux-next-20100407/net/core/dev_addr_lists.c: In function 'dev_mc_net_init':
linux-next-20100407/net/core/dev_addr_lists.c:722: error: implicit declaration of function 'proc_net_fops_create'
linux-next-20100407/net/core/dev_addr_lists.c:722: error: 'dev_mc_seq_fops' undeclared (first use in this function)
linux-next-20100407/net/core/dev_addr_lists.c:722: error: (Each undeclared identifier is reported only once
linux-next-20100407/net/core/dev_addr_lists.c:722: error: for each function it appears in.)
linux-next-20100407/net/core/dev_addr_lists.c: In function 'dev_mc_net_exit':
linux-next-20100407/net/core/dev_addr_lists.c:729: error: implicit declaration of function 'proc_net_remove'
make[3]: *** [net/core/dev_addr_lists.o] Error 1

---
~Randy
