From: David Miller <davem@davemloft.net>
Subject: Re: pull request net: batman-adv 2013-05-09
Date: Sat, 11 May 2013 16:24:23 -0700 (PDT)
Message-ID: <20130511.162423.332204083485209564.davem@davemloft.net>
References: <1368097007-817-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60246 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491Ab3EKXYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 May 2013 19:24:24 -0400
In-Reply-To: <1368097007-817-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Thu,  9 May 2013 12:56:43 +0200

> here you have four fixes intended for net.
> 
> 1/4 fixes the parsing of a string sent from userspace in order to avoid random
> memory access in case of string length of 0.
> 
> 2/4 adds a check for the return value of pskb_trim_rcsum() in order to stop
> processing the skb in case of failure.
> 
> 3/4 prevents DAT (the Distributed ARP Table) to send cached ARP replies when
> both the source and the destination of the snooped ARP request are local clients
> (meaning: directly connected to the node). This can confuse a bridge where
> batman-adv is enslaved.
> 
> 4/4 fix a race condition in the main clean up procedure by reordering
> sub-components freeing function invocations.
> 
> Please pull or let me know if there is any problem.

Pulled, thanks Antonio.
