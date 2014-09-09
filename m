From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] openvswitch: change the data type of error
 status to atomic_long_t
Date: Tue, 09 Sep 2014 11:47:48 -0700 (PDT)
Message-ID: <20140909.114748.1778878806000997918.davem@davemloft.net>
References: <1410001571-13338-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59546 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320AbaIISrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 14:47:48 -0400
In-Reply-To: <1410001571-13338-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Sat,  6 Sep 2014 19:06:11 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> Change the date type of error status from u64 to atomic_long_t, and use atomic
> operation, then remove the lock which is used to protect the error status.
> 
> The operation of atomic maybe faster than spin lock.
> 
> Cc: Pravin Shelar <pshelar@nicira.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

I think in the final analysis this is a good change, it shrinks a
datastructure by eliminating a spinlock, and the performance impact
is a non-argument since these are not happening in performance
critical paths.

So I am going to apply this, thanks.
