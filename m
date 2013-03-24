From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] 8021q: fix a potential use-after-free
Date: Sun, 24 Mar 2013 17:27:56 -0400 (EDT)
Message-ID: <20130324.172756.1733514118551455926.davem@davemloft.net>
References: <1363938600-26129-1-git-send-email-amwang@redhat.com>
	<1364015648-4195-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755077Ab3CXV15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 17:27:57 -0400
In-Reply-To: <1364015648-4195-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Sat, 23 Mar 2013 13:14:07 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> vlan_vid_del() could possibly free ->vlan_info after a RCU grace
> period, however, we may still refer to the freed memory area
> by 'grp' pointer. Found by code inspection.
> 
> This patch moves vlan_vid_del() as behind as possible.
> 
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
