From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] netlink: fix NETLINK_RECV_NO_ENOBUFS in
 netlink_set_err()
Date: Sat, 20 Mar 2010 14:30:27 -0700 (PDT)
Message-ID: <20100320.143027.116368032.davem@davemloft.net>
References: <4BA25C82.7000301@netfilter.org>
	<4BA26138.6070709@trash.net>
	<4BA2C44A.1000100@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35231
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751403Ab0CTVaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 17:30:04 -0400
In-Reply-To: <4BA2C44A.1000100@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri, 19 Mar 2010 01:24:42 +0100

> Patrick McHardy wrote:
>> Generally the logic seems inverted, you should return an error
>> to conntrack if userspace wasn't notified of the error.
> 
> Indeed, thanks. Are you OK with this patch instead?

I went over all of this and now the patches #1 and #2 look
correct to me, so I've applied them to net-2.6

Patrick let me know if you think any follow-on tidy ups
are still necessary and we can add them.

Thanks Pablo!
