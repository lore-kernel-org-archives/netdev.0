From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [ipv6]: adjust inet6_exit() cleanup sequence against
 inet6_init()
Date: Tue, 20 Feb 2007 01:30:53 -0800 (PST)
Message-ID: <20070220.013053.78711208.davem@davemloft.net>
References: <20070209093424.GA7078@joejin-pc.cn.oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: joe.jin@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57706
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932508AbXBTJaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 04:30:55 -0500
In-Reply-To: <20070209093424.GA7078@joejin-pc.cn.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Jin <joe.jin@oracle.com>
Date: Fri, 9 Feb 2007 17:34:24 +0800

> This patch for adjust inet6_exit() to inverse sequence to inet6_init().
> 
> At ipv6_init, it first create proc_root/net/dev_snmp6 entry by call
> ipv6_misc_proc_init(), then call addrconf_init() to create the corresponding
> device entry at this directory, but at inet6_exit, ipv6_misc_proc_exit()
> called first, then call addrconf_init().
> 
> Signed-off-by: Joe Jin <joe.jin@oracle.com>

Good thing ipv6 can never be unloaded :-)

Nevertheless, if the unload exit function exists, it ought
to be correct.

Patch applied, thank you.
