From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bridge: message age needs to increase, not
 decrease.
Date: Sun, 04 Mar 2012 21:57:57 -0500 (EST)
Message-ID: <20120304.215757.221849809842337285.davem@davemloft.net>
References: <1330625539-10247-1-git-send-email-Joakim.Tjernlund@transmode.se>
	<1330625539-10247-2-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joakim.Tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47936 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335Ab2CEC6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 21:58:02 -0500
In-Reply-To: <1330625539-10247-2-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Date: Thu, 1 Mar 2012 19:12:19 +0100

> commit bridge: send proper message_age in config BPDU
> added this gem:
>   bpdu.message_age = (jiffies - root->designated_age)
>   p->designated_age = jiffies + bpdu->message_age;
> Notice how bpdu->message_age is negated when reassigned to
> bpdu.message_age. This causes message age to decrease breaking the
> STP protocol.
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>

Applied.
