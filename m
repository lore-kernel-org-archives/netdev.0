From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] neigh: fix setting of default gc_* values
Date: Sat, 22 Feb 2014 00:09:08 -0500 (EST)
Message-ID: <20140222.000908.1152977118961189337.davem@davemloft.net>
References: <1392990777-9446-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gaofeng@cn.fujitsu.com,
	hannes@stressinduktion.org, joe@perches.com, vfalico@redhat.com,
	ffusco@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46247 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248AbaBVFJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 00:09:05 -0500
In-Reply-To: <1392990777-9446-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 21 Feb 2014 14:52:57 +0100

> This patch fixes bug introduced by:
> commit 1d4c8c29841b9991cdf3c7cc4ba7f96a94f104ca
> "neigh: restore old behaviour of default parms values"
> 
> The thing is that in neigh_sysctl_register, extra1 and extra2 which were
> previously set for NEIGH_VAR_GC_* are overwritten. That leads to
> nonsense int limits for gc_* variables. So fix this by not touching
> extra* fields for gc_* variables.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Good catch, applied and queued up for -stable.

Thanks!
