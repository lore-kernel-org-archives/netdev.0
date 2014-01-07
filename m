From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gre_offload: statically build GRE offloading
 support
Date: Mon, 06 Jan 2014 20:28:58 -0500 (EST)
Message-ID: <20140106.202858.1587542022573250516.davem@davemloft.net>
References: <1388896679-23152-1-git-send-email-hkchu@google.com>
	<1389045787.26646.9.camel@edumazet-glaptop2.roam.corp.google.com>
	<1389047695.26646.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, herbert@gondor.apana.org.au,
	ogerlitz@mellanox.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36663 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754400AbaAGB27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 20:28:59 -0500
In-Reply-To: <1389047695.26646.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 06 Jan 2014 14:34:55 -0800

> On Mon, 2014-01-06 at 14:03 -0800, Eric Dumazet wrote:
> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: H.K. Jerry Chu <hkchu@google.com>
>> ---
>> Note : We probably can remove EXPORT_SYMBOL() on inet_add_offload()
>> and inet_del_protocol() on a followup patch if there is interest.
> 
> 
> There is a typo on this note, of course : inet_del_offload() was
> intended, not inet_del_protocol()

Understood.

This looks a lot better, applied, thanks.
