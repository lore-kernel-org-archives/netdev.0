From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vmxnet3: use initialized skb pointer to set
 hash
Date: Thu, 26 Dec 2013 13:55:50 -0500 (EST)
Message-ID: <20131226.135550.2298502869621990728.davem@davemloft.net>
References: <1387541817-7877-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51873 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753727Ab3LZSzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 13:55:52 -0500
In-Reply-To: <1387541817-7877-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Fri, 20 Dec 2013 13:16:57 +0100

> The recent conversion to skb_set_hash() was incorrect. 'skb' is
> uninitialized at this point.
> 
> Fixes: 0b6807034791 ('net: vmxnet3 calls skb_set_hash')
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Applied, thank you.
