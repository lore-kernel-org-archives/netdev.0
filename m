From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] openvswitch: Fix helper reference leak
Date: Fri, 11 Dec 2015 23:32:39 -0500 (EST)
Message-ID: <20151211.233239.1402150092760241430.davem@davemloft.net>
References: <1449698860-20685-1-git-send-email-joe@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: joe@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60923 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754486AbbLLEcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 23:32:45 -0500
In-Reply-To: <1449698860-20685-1-git-send-email-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@ovn.org>
Date: Wed,  9 Dec 2015 14:07:39 -0800

> If the actions (re)allocation fails, or the actions list is larger than the
> maximum size, and the conntrack action is the last action when these
> problems are hit, then references to helper modules may be leaked. Fix
> the issue.
> 
> Fixes: cae3a2627520 ("openvswitch: Allow attaching helpers to ct action")
> Signed-off-by: Joe Stringer <joe@ovn.org>

Applied and queued up for -stable.
