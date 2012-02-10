From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: Fix wrong order of ip_rt_get_source() and
 update iph->daddr.
Date: Fri, 10 Feb 2012 15:12:40 -0500 (EST)
Message-ID: <20120210.151240.26010371437547242.davem@davemloft.net>
References: <4F34BDAD.8080608@cn.fujitsu.com>
	<4F34C40D.5010503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41468 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760091Ab2BJUMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 15:12:45 -0500
In-Reply-To: <4F34C40D.5010503@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Fri, 10 Feb 2012 15:15:25 +0800

> This patch fix a bug which introduced by commit ac8a4810 (ipv4: Save
> nexthop address of LSRR/SSRR option to IPCB.).In that patch, we saved
> the nexthop of SRR in ip_option->nexthop and update iph->daddr until
> we get to ip_forward_options(), but we need to update it before 
> ip_rt_get_source(), otherwise we may get a wrong src.
> 
> Signed-off-by: Li Wei <lw@cn.fujitsu.com>

Applied, thanks.
