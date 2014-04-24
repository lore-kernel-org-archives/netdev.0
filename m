From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 4/4] bonding: Add tlb_dynamic_lb parameter for tlb
 mode
Date: Thu, 24 Apr 2014 13:05:18 -0400 (EDT)
Message-ID: <20140424.130518.1397102659170608563.davem@davemloft.net>
References: <1398209422-3873-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	netdev@vger.kernel.org, edumazet@google.com, maze@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758599AbaDXRFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 13:05:21 -0400
In-Reply-To: <1398209422-3873-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Tue, 22 Apr 2014 16:30:22 -0700

> The aggresive load balancing causes packet re-ordering as active
> flows are moved from a slave to another within the group. Sometime
> this aggresive lb is not necessary if the preference is for less
> re-ordering. This parameter if used with value "0" disables
> this dynamic flow shuffling minimizing packet re-ordering. Of course
> the side effect is that it has to live with the static load balancing
> that the hashing distribution provides. This impact is less severe if
> the correct xmit-hashing-policy is used for the tlb setup.
> 
> The default value of the parameter is set to "1" mimicing the earlier
> behavior.
> 
> Ran the netperf test with 200 stream for 1 min between two hosts with
> 4x1G trunk (xmit-lb mode with xmit-policy L3+4) before and after these
> changes. Following was the command used for those 200 instances -
> 
>     netperf -t TCP_RR -l 60 -s 5 -H <host> -- -r81920,81920
> 
> Transactions per second:
>     Before change: 1,367.11
>     After  change: 1,470.65
> 
> Change-Id: Ie3f75c77282cf602e83a6e833c6eb164e72a0990
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied.
