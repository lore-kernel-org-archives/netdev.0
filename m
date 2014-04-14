From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: return valid RTA_IIF on ip route get
Date: Sun, 13 Apr 2014 23:24:08 -0400 (EDT)
Message-ID: <20140413.232408.2160730307149131073.davem@davemloft.net>
References: <1397401682-8615-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49542 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbaDNDYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2014 23:24:10 -0400
In-Reply-To: <1397401682-8615-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sun, 13 Apr 2014 18:08:02 +0300

> Extend commit 13378cad02afc2adc6c0e07fca03903c7ada0b37
> ("ipv4: Change rt->rt_iif encoding.") from 3.6 to return valid
> RTA_IIF on 'ip route get ... iif DEVICE' instead of rt_iif 0
> which is displayed as 'iif *'.
> 
> inet_iif is not appropriate to use because skb_iif is not set.
> Use the skb->dev->ifindex instead.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied and queued up for -stable, thanks Julian.
