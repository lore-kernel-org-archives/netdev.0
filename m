From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 27212] New: Warning kmemcheck: Caught 64-bit
 read from uninitialized memory in netlink_broadcast_filtered
Date: Thu, 27 Jan 2011 14:41:29 -0800 (PST)
Message-ID: <20110127.144129.246526810.davem@davemloft.net>
References: <bug-27212-10286@https.bugzilla.kernel.org/>
	<20110120122549.85863a84.akpm@linux-foundation.org>
	<1296033518.2899.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, casteyde.christian@free.fr,
	akpm@linux-foundation.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54921
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751373Ab1A0Wky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 17:40:54 -0500
In-Reply-To: <1296033518.2899.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 26 Jan 2011 10:18:38 +0100

> [PATCH] net: add kmemcheck annotation in __alloc_skb()
> 
> pskb_expand_head() triggers a kmemcheck warning when copy of
> skb_shared_info is done in pskb_expand_head()
> 
> This is because destructor_arg field is not necessarily initialized at
> this point. Add kmemcheck_annotate_variable() call in __alloc_skb() to
> instruct kmemcheck this is a normal situation.
> 
> Resolves bugzilla.kernel.org 27212
> 
> Reference: https://bugzilla.kernel.org/show_bug.cgi?id=27212
> Reported-by: Christian Casteyde <casteyde.christian@free.fr>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>

Applied, thanks Eric.
