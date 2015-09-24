From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] skbuff: Fix skb checksum flag on skb pull
Date: Thu, 24 Sep 2015 14:09:31 -0700 (PDT)
Message-ID: <20150924.140931.1967362456389755405.davem@davemloft.net>
References: <1442951873-4803-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54150 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753768AbbIXVJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 17:09:34 -0400
In-Reply-To: <1442951873-4803-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue, 22 Sep 2015 12:57:53 -0700

> VXLAN device can receive skb with checksum partial. But the checksum
> offset could be in outer header which is pulled on receive. This results
> in negative checksum offset for the skb. Such skb can cause the assert
> failure in skb_checksum_help(). Following patch fixes the bug by setting
> checksum-none while pulling outer header.
> 
> Following is the kernel panic msg from old kernel hitting the bug.
 ...
> Reported-by: Anupam Chanda <achanda@vmware.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied, thanks.
