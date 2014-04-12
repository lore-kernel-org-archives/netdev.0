From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] pktgen: be friendly to LLTX devices
Date: Sat, 12 Apr 2014 02:01:27 -0400 (EDT)
Message-ID: <20140412.020127.389030105332580550.davem@davemloft.net>
References: <1397215320-1838-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com, edumazet@google.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33590 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbaDLGB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2014 02:01:28 -0400
In-Reply-To: <1397215320-1838-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 11 Apr 2014 13:22:00 +0200

> Similarly to commit 43279500deca ("packet: respect devices with
> LLTX flag in direct xmit"), we can basically apply the very same
> to pktgen. This will help testing against LLTX devices such as
> dummy driver (or others), which only have a single netdevice txq
> and would otherwise require locking their txq from pktgen side
> while e.g. in dummy case, we would not need any locking. Fix this
> by making use of HARD_TX_{UN,}LOCK API, so that NETIF_F_LLTX will
> be respected.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied.
