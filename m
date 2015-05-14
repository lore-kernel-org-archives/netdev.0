From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] packet: fix warnings in rollover lock
 contention
Date: Thu, 14 May 2015 17:41:36 -0400 (EDT)
Message-ID: <20150514.174136.1751915445355356147.davem@davemloft.net>
References: <1431631502-19417-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42268 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422821AbbENVli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 17:41:38 -0400
In-Reply-To: <1431631502-19417-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Thu, 14 May 2015 15:25:02 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Avoid two xchg calls whose return values were unused, causing a
> warning on some architectures.
> 
> The relevant variable is a hint and read without mutual exclusion.
> This fix makes all writers hold the receive_queue lock.
> 
> Suggested-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Looks great, thanks for dealing with the locking problem.
