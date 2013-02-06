From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: adjust skb_gso_segment() for calling
 in rx path
Date: Wed, 06 Feb 2013 15:58:40 -0500 (EST)
Message-ID: <20130206.155840.401066341279523511.davem@davemloft.net>
References: <1360118198-25440-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758637Ab3BFU6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 15:58:43 -0500
In-Reply-To: <1360118198-25440-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed,  6 Feb 2013 10:36:38 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> skb_gso_segment() is almost always called in tx path,
> except for openvswitch. It calls this function when
> it receives the packet and tries to queue it to user-space.
> In this special case, the ->ip_summed check inside
> skb_gso_segment() is no longer true, as ->ip_summed value
> has different meanings on rx path.
> 
> This patch adjusts skb_gso_segment() so that we can at least
> avoid such warnings on checksum.
> 
> Cc: Jesse Gross <jesse@nicira.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

This looks perfect, applied, thanks!
