From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6.24][NETNS][patch 1/1] fix allnoconfig compilation
 error
Date: Thu, 13 Sep 2007 00:17:22 -0700 (PDT)
Message-ID: <20070913.001722.112600272.davem@davemloft.net>
References: <20070913060151.898030855@mai.toulouse-stg.fr.ibm.com>
	<20070913060545.740930015@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:49781
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751312AbXIMHRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 03:17:31 -0400
In-Reply-To: <20070913060545.740930015@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: dlezcano@fr.ibm.com
Date: Thu, 13 Sep 2007 08:01:52 +0200

> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> 
> When CONFIG_NET=no, init_net is unresolved because net_namespace.c
> is not compiled and the include pull init_net definition.
> 
> This problem was very similar with the ipc namespace where the kernel
> can be compiled with SYSV ipc out.
> 
> This patch fix that defining a macro which simply remove init_net
> initialization from nsproxy namespace aggregator.
> 
> Compiled and booted on qemu-i386 with CONFIG_NET=no and CONFIG_NET=yes.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied to net-2.6.24, thanks.
