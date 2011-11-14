From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix a memory leak in ic_bootp_send_if
Date: Mon, 14 Nov 2011 14:38:05 -0500 (EST)
Message-ID: <20111114.143805.872719770519430363.davem@davemloft.net>
References: <1321257248-14175-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963Ab1KNTiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 14:38:08 -0500
In-Reply-To: <1321257248-14175-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Mon, 14 Nov 2011 15:54:08 +0800

> From: RongQing.Li <roy.qing.li@gmail.com>
> 
> when dev_hard_header() failed, the newly allocated skb should be freed.
> 
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>

Applied.
