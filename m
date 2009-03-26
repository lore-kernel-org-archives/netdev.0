From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] netfilter: fix warning in ebt_ulog init function.
Date: Thu, 26 Mar 2009 01:04:09 -0700 (PDT)
Message-ID: <20090326.010409.92816273.davem@davemloft.net>
References: <1238053819.13879.4.camel@ice-age>
	<1238054396-9088-2-git-send-email-eric@inl.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: eric@inl.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56405
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752730AbZCZIEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 04:04:21 -0400
In-Reply-To: <1238054396-9088-2-git-send-email-eric@inl.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Leblond <eric@inl.fr>
Date: Thu, 26 Mar 2009 08:59:55 +0100

> The ebt_ulog module does not follow the fixed convention about function
> return. Loading the module is triggering the following message:
> 
> sys_init_module: 'ebt_ulog'->init suspiciously returned 1, it should follow 0/-E convention
> sys_init_module: loading module anyway...
> Pid: 2334, comm: modprobe Not tainted 2.6.29-rc5edenwall0-00883-g199e57b #146
> Call Trace:
>  [<c0441b81>] ? printk+0xf/0x16
>  [<c02311af>] sys_init_module+0x107/0x186
>  [<c0202cfa>] syscall_call+0x7/0xb
> 
> The following patch fixes the return treatment in ebt_ulog_init()
> function.
> 
> Signed-off-by: Eric Leblond <eric@inl.fr>

Applied.
