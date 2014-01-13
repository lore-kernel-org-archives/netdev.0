From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] bonding: ensure that the TSO being set on bond
 master
Date: Mon, 13 Jan 2014 11:15:11 -0800 (PST)
Message-ID: <20140113.111511.1204304092822372663.davem@davemloft.net>
References: <52CCFE15.2020605@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, edumazet@google.com,
	netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37965 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555AbaAMTPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 14:15:12 -0500
In-Reply-To: <52CCFE15.2020605@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Wed, 8 Jan 2014 15:28:21 +0800

> The commit b0ce3508(bonding: allow TSO being set on bonding master)
> has make the TSO being set for bond dev, but in some situation, if
> the slave did not have the NETIF_F_SG features, the bond master will
> miss the TSO features in netdev_fix_features because the TSO is
> depended on SG. So I have to add SG and TSO features on bond master
> together.
> 
> The function netdev_add_tso_features() was only be used for bonding,
> so no need to export it in netdevice.h, remove it and add it to bonding.

As far as I can tell from the discussion, there is some issue wrt. TSO
about what happens if SG is not supported by some of the slaves.

>From my perspective it appears that some changes to these patches are
necessary to handle that correctly.

So I am going to mark them as "Changes Requested" in patchwork.

If this is not the case, please resubmit these changes with appropriate
explanations added to the commit message(s).

Thanks.
