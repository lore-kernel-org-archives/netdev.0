From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Add __dev_forward_skb
Date: Tue, 08 Apr 2014 12:27:39 -0400 (EDT)
Message-ID: <20140408.122739.1963541036894784.davem@davemloft.net>
References: <E1WX4P1-0006vx-NF@gondolin.me.apana.org.au>
	<20140407114854.135e2e6c@nehalam.linuxnetplumber.net>
	<20140408071518.GA2694@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43263 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932078AbaDHQ1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 12:27:41 -0400
In-Reply-To: <20140408071518.GA2694@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 8 Apr 2014 15:15:18 +0800

> On Mon, Apr 07, 2014 at 11:48:54AM -0700, Stephen Hemminger wrote:
>> On Mon, 07 Apr 2014 15:55:35 +0800
>> Herbert Xu <herbert@gondor.apana.org.au> wrote:
>> 
>> > +}
>> > +EXPORT_SYMBOL_GPL(__dev_forward_skb);
>> > +
>> 
>> Don't export a symbol without a followup patch that uses it.
> 
> Sorry but I screwed the threading so the follow-up patch is in its
> own thread.  But I assure you that this symbol is used in the
> follow-up :)

Yeah I was going to mention that to Stephen too :-)
