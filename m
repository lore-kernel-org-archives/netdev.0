From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2013-03-28
Date: Thu, 28 Mar 2013 14:34:43 -0400 (EDT)
Message-ID: <20130328.143443.1091407364578033264.davem@davemloft.net>
References: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44290 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753578Ab3C1Sep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 14:34:45 -0400
In-Reply-To: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Thu, 28 Mar 2013 08:50:20 +0100

> here you have another batch of patches intended for net-next/linux-3.10.
> 
> The first one fixes an endianess bug in the new network coding component,
> sent within our last pull request. It was discovered thanks to
> Fengguang Wu's automated daily checks on our tree (we upgraded our daily
> check to look for endianess bugs as well ;-))
> 
> Then you have patches from 2/11 to 8/11 implementing the RTNL API for virtual
> interfaces manipulation: now users can use the "ip" tool to create/delete
> batman-adv interfaces and to enslave real ones below them. However, to avoid
> breaking any user tool, we did not disrupt our sysfs API.
> 
> Patch 11/11 is addressing a new checkpatch complaining by substituting seq_printf
> with seq_puts when possible (however, checkpatch seems to be broken because it
> raises false positives in case of multi-line seq_printf).
> 
> The rest is ordinary house keeping.

Pulled, thanks.
