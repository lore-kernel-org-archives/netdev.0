From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] Handle stuck TX queue bug in AT8030 PHY
Date: Sat, 21 Jun 2014 15:51:13 -0700 (PDT)
Message-ID: <20140621.155113.677176502129866161.davem@davemloft.net>
References: <1403082103-23709-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	marek.belisko@gmail.com, ujhelyi.m@gmail.com
To: zonque@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40131 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121AbaFUWvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2014 18:51:14 -0400
In-Reply-To: <1403082103-23709-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <zonque@gmail.com>
Date: Wed, 18 Jun 2014 11:01:40 +0200

> These three small patches circument a hardware bug in AT8030 PHYs that
> leads to stuck TX FIFO queues when the link goes away while there are
> pending patches in der outbound queue. This bug has been confirmed by
> the vendor, and their only proposed fix is to apply a hardware reset
> every time the link goes down.
...
> v1 -> v2:
> 	* Rename phy device callback from adjust_state to link_change_notify

Series applied, thanks Daniel.
