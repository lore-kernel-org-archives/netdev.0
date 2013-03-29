From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] core: fix the use of this_cpu_ptr
Date: Fri, 29 Mar 2013 15:13:52 -0400 (EDT)
Message-ID: <20130329.151352.1483855650528080103.davem@davemloft.net>
References: <1364463761-32510-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56143 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756784Ab3C2TNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 15:13:54 -0400
In-Reply-To: <1364463761-32510-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu, 28 Mar 2013 17:42:41 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> flush_tasklet is not percpu var, and percpu is percpu var, and
> 	this_cpu_ptr(&info->cache->percpu->flush_tasklet)
> is not equal to
> 	&this_cpu_ptr(info->cache->percpu)->flush_tasklet
> 
> 1f743b076(use this_cpu_ptr per-cpu helper) introduced this bug.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.
