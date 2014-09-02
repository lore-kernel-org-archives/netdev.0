From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] openvswitch: fix a memory leak
Date: Tue, 02 Sep 2014 14:01:36 -0700 (PDT)
Message-ID: <20140902.140136.2221556191862322749.davem@davemloft.net>
References: <1409662348-2475-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, pshelar@nicira.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58588 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755130AbaIBVBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 17:01:37 -0400
In-Reply-To: <1409662348-2475-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Tue,  2 Sep 2014 20:52:28 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> The user_skb maybe be leaked if the operation on it failed and codes
> skipped into the label "out:" without calling genlmsg_unicast.
> 
> Cc: Pravin Shelar <pshelar@nicira.com> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.
