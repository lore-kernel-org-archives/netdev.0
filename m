From: James Chapman <jchapman@katalix.com>
Subject: Re: [patch 7/7] pppol2tp: fix printk warnings
Date: Fri, 08 Feb 2008 15:40:52 +0000
Message-ID: <47AC7804.2040001@katalix.com>
References: <200802081120.m18BK9QQ021642@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeff@garzik.org, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:55469 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756723AbYBHPlI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2008 10:41:08 -0500
In-Reply-To: <200802081120.m18BK9QQ021642@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> drivers/net/pppol2tp.c: In function `pppol2tp_seq_tunnel_show':
> drivers/net/pppol2tp.c:2295: warning: long long unsigned int format, __u64 arg (arg 4)
> drivers/net/pppol2tp.c:2295: warning: long long unsigned int format, __u64 arg (arg 5)
> drivers/net/pppol2tp.c:2295: warning: long long unsigned int format, __u64 arg (arg 6)
> drivers/net/pppol2tp.c:2295: warning: long long unsigned int format, __u64 arg (arg 7)
> drivers/net/pppol2tp.c:2295: warning: long long unsigned int format, __u64 arg (arg 8)
> drivers/net/pppol2tp.c:2295: warning: long long unsigned int format, __u64 arg (arg 9)
> drivers/net/pppol2tp.c: In function `pppol2tp_seq_session_show':
> drivers/net/pppol2tp.c:2328: warning: long long unsigned int format, __u64 arg (arg 5)
> drivers/net/pppol2tp.c:2328: warning: long long unsigned int format, __u64 arg (arg 6)
> drivers/net/pppol2tp.c:2328: warning: long long unsigned int format, __u64 arg (arg 7)
> drivers/net/pppol2tp.c:2328: warning: long long unsigned int format, __u64 arg (arg 8)
> drivers/net/pppol2tp.c:2328: warning: long long unsigned int format, __u64 arg (arg 9)
> drivers/net/pppol2tp.c:2328: warning: long long unsigned int format, __u64 arg (arg 10)
> 
> Not all platforms implement u64 with unsigned long long.  eg: powerpc.
> 
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: James Chapman <jchapman@katalix.com>

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

