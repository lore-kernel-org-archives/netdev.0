From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5 net-next] rhashtable: Disable automatic shrinking
 by default
Date: Tue, 24 Mar 2015 15:29:24 -0400 (EDT)
Message-ID: <20150324.152924.921970094708836276.davem@davemloft.net>
References: <cover.1427202823.git.tgraf@suug.ch>
	<f6ed6e9fe9434e55475b777281f6fe67eff0e07d.1427202823.git.tgraf@suug.ch>
	<20150324185545.GA15837@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38809 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbbCXT30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 15:29:26 -0400
In-Reply-To: <20150324185545.GA15837@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 25 Mar 2015 05:55:45 +1100

> On Tue, Mar 24, 2015 at 02:18:19PM +0100, Thomas Graf wrote:
>> Using rhashtable_remove_fast() will no longer automatically
>> shrink the table. Users need to opt-in to shrinking by
>> explicitly using rhashtable_remove_and_shrink()
>> 
>> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Note that this patch doesn't completely disable automatic shrinking
> since the worker thread can still trigger it.

Ok, but how do you feel about Thomas's series otherwise?

It looks fine to me.
