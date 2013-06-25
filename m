From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: don't disable interface if last ipv6
 address is removed
Date: Tue, 25 Jun 2013 16:24:04 -0700 (PDT)
Message-ID: <20130625.162404.1739290747766756693.davem@davemloft.net>
References: <20130623222220.GD13836@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34911 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774Ab3FYXYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 19:24:05 -0400
In-Reply-To: <20130623222220.GD13836@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 24 Jun 2013 00:22:20 +0200

> The reason behind this change is that as soon as we delete
> the last ipv6 address of an interface we also lose the
> /proc/sys/net/ipv6/conf/<interface> directory. This seems to be a
> usability problem for me.
> 
> I don't see any reason why we should shutdown ipv6 on that interface in
> such cases.
> 
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
