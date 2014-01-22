From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] packet: fix a couple of cppcheck warnings
Date: Tue, 21 Jan 2014 16:52:03 -0800 (PST)
Message-ID: <20140121.165203.304954372532831580.davem@davemloft.net>
References: <1390128413-7075-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbaAVAwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 19:52:04 -0500
In-Reply-To: <1390128413-7075-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sun, 19 Jan 2014 11:46:53 +0100

> Doesn't bring much, but also doesn't hurt us to fix 'em:
> 
> 1) In tpacket_rcv() flush dcache page we can restirct the scope
>    for start and end and remove one layer of indent.
> 
> 2) In tpacket_destruct_skb() we can restirct the scope for ph.
> 
> 3) In alloc_one_pg_vec_page() we can remove the NULL assignment
>    and change spacing a bit.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks.
