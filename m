From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: 2.6.24-git6 net build failure when SYSFS=n, PROC_FS=n
Date: Wed, 30 Jan 2008 09:05:48 +0100
Message-ID: <47A02FDC.1050309@fr.ibm.com>
References: <20080129160254.b7ff01bc.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:7538 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbYA3IKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 03:10:20 -0500
In-Reply-To: <20080129160254.b7ff01bc.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Randy Dunlap wrote:
> linux-2.6.24-git6/net/ipv4/fib_frontend.c: In function 'fib_net_init':
> linux-2.6.24-git6/net/ipv4/fib_frontend.c:1024: error: implicit declaration of function 'fib_proc_init'
> linux-2.6.24-git6/net/ipv4/fib_frontend.c: In function 'fib_net_exit':
> linux-2.6.24-git6/net/ipv4/fib_frontend.c:1039: error: implicit declaration of function 'fib_proc_exit'
> 
> linux-2.6.24-git6/net/ipv6/sysctl_net_ipv6.c: In function 'ipv6_sysctl_net_init':
> linux-2.6.24-git6/net/ipv6/sysctl_net_ipv6.c:71: error: implicit declaration of function 'ipv6_route_sysctl_init'
> linux-2.6.24-git6/net/ipv6/sysctl_net_ipv6.c:71: warning: assignment makes pointer from integer without a cast
> linux-2.6.24-git6/net/ipv6/sysctl_net_ipv6.c:75: error: implicit declaration of function 'ipv6_icmp_sysctl_init'
> linux-2.6.24-git6/net/ipv6/sysctl_net_ipv6.c:75: warning: assignment makes pointer from integer without a cast
> 
> 
> config attached.
> 
> ---
> ~Randy

Hi,

thanks for catching this. I sent a fix for these two compilation errors 
a few days ago. I guess they will be merged very soon by Dave.

   -- Daniel
