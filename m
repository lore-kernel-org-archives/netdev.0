From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: bond failover doesn't happen when active slave link is up, but
 there is no connectivity
Date: Tue, 4 Mar 2014 09:40:29 +0800
Message-ID: <53152F0D.2050500@huawei.com>
References: <62EB227014B44F00A9ACC9C781887FC8@alyakaslap>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Alex Lyakas <alex@zadarastorage.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:6279 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755147AbaCDBk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 20:40:57 -0500
In-Reply-To: <62EB227014B44F00A9ACC9C781887FC8@alyakaslap>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/4 0:49, Alex Lyakas wrote:
> Greetings all,
> We are using bonding interfaces in active-backup (1) mode, with "fail_over_mac" set to "active" (1), with miimon=100 and two slaves. The slaves are "either regular" network interfaces, or vlan interfaces created with "vconfig" over "regular" interfaces. One of the slaves is defined as primary. The purpose of this config is to ensure failover in case one of the interfaces dies. This config usually works as expected.
> 
> One scenario that doesn't work for us, is when link status of the active slave is up, but all the packets sent to it are dropped, e.g., because of
> incorrect switch configuration. In that case bond failover doesn't happen. Can this scenario be addressed with bonding?
> 
> Thanks,
> Alex.
> 
> I found a discussion, which looks relevant, labeled "How to check an inactive slave in a bond?" in http://www.spinics.net/lists/lartc/msg21434.html". But this discussion considers the inactive slave, while in my case, I would like to better handle problems with the active slave.
> 
Hi Alex:

I don't understand your problem clearly, normally the fail_over_mac could work well, but in some strange situation, just like the active slave down and up, but
it could not work back again, can you explain your steps to reproduction the problem, I think I can meet the same problem?

Regards
Ding

> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
