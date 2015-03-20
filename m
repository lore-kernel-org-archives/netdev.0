From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] inet: tcp listener refactoring part 14
Date: Fri, 20 Mar 2015 12:54:01 -0400 (EDT)
Message-ID: <20150320.125401.298074076331365269.davem@davemloft.net>
References: <1426817061-21421-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35587 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637AbbCTQyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 12:54:04 -0400
In-Reply-To: <1426817061-21421-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Thu, 19 Mar 2015 19:04:18 -0700

> OK, we have serious patches here.
> 
> We get rid of the central timer handling SYNACK rtx,
> which is killing us under even medium SYN flood.
> 
> We still use the listener specific hash table.
> 
> This will be done in next round ;)

Looks great, series applied, thanks Eric.
