From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6 0/2] bonding: create same number of queues
 on all creations
Date: Thu, 11 Aug 2011 07:44:54 -0700 (PDT)
Message-ID: <20110811.074454.1413604682491709959.davem@davemloft.net>
References: <1312992585-1201-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49558 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741Ab1HKOqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 10:46:09 -0400
In-Reply-To: <1312992585-1201-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 10 Aug 2011 18:09:43 +0200

> When bonding device is created via /sys/class/net/bonding_masters,
> correct number of queues is created. But if bonding device is created via rtnl,
> default single queue is created. This little patchset makes it behaves the same.
> 
> Jiri Pirko (2):
>   bonding: implement get_tx_queues rtnk_link_op
>   rtnetlink: remove initialization of dev->real_num_tx_queues

Both applied, thanks Jiri.
