From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipv6 : ip6mr.c : Fix can't match the IPv6
 multicast packets with input net device in netfilter FORWARD chain.
Date: Thu, 02 Aug 2012 16:20:15 -0700 (PDT)
Message-ID: <20120802.162015.2106150087918919160.davem@davemloft.net>
References: <1343912455-4444-1-git-send-email-mypopydev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: mypopydev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59683 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754069Ab2HBXUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 19:20:16 -0400
In-Reply-To: <1343912455-4444-1-git-send-email-mypopydev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jun Zhao <mypopydev@gmail.com>
Date: Thu,  2 Aug 2012 21:00:55 +0800

> Current kernel change the skb's net device with output device before netfilter FORWARD chain,
> that will lead to can't match the IPv6 multicast packets with input net device in netfilter
> FORWARD chain.
> 
> the test case for reproduce this issue as follow:
> 
> IPv6 multicast udp stream from eth0(input device) to eth1(output device)

Your change means we now can't match on the VIF device in this situation.

I'm not applying this patch, it breaks as much as it fixes.
