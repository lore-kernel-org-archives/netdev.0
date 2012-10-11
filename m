From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] xen: netback: handle compound page fragments on
 transmit.
Date: Wed, 10 Oct 2012 22:54:05 -0400 (EDT)
Message-ID: <20121010.225405.819531775702809174.davem@davemloft.net>
References: <1349876922-11907-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	eric.dumazet@gmail.com, konrad@kernel.org, linux@eikelenboom.it
To: ian.campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58909 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754809Ab2JKCyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 22:54:07 -0400
In-Reply-To: <1349876922-11907-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <ian.campbell@citrix.com>
Date: Wed, 10 Oct 2012 14:48:42 +0100

> An SKB paged fragment can consist of a compound page with order > 0.
> However the netchannel protocol deals only in PAGE_SIZE frames.
> 
> Handle this in netbk_gop_frag_copy and xen_netbk_count_skb_slots by
> iterating over the frames which make up the page.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>

Applied.
