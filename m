From: Patrick McHardy <kaber@trash.net>
Subject: Re: [0/10] Remove sk_buff ** from netfilter API
Date: Mon, 15 Oct 2007 08:25:35 +0200
Message-ID: <471307DF.4090302@trash.net>
References: <E1IbT8r-0000Av-00@gondolin.me.apana.org.au> <46FE6D73.4000002@trash.net> <20070929.171339.59681016.davem@davemloft.net> <20070930002601.GB7502@gondor.apana.org.au> <20070930004341.GA7769@gondor.apana.org.au> <46FFC2F4.8090602@trash.net> <20071014042604.GA11431@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35184 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755143AbXJOG0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 02:26:07 -0400
In-Reply-To: <20071014042604.GA11431@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Sun, Sep 30, 2007 at 05:38:28PM +0200, Patrick McHardy wrote:
>> >From a quick look it seems at least IPv4 and IPv6 don't need to
>> change the skb anywhere else. It seems to be necessary for
>> bridging though to unshare the skb. OTOH br_netfilter.c already
>> unshares the skb for IPv4 and IPv6, so we could simply do this
>> unconditionally before calling the hooks.
> 
> Thanks.  I got bored and finally did the plunge :)
> 
> I've booted it here and it seems to work.


Thanks Herbert :) I'll have a closer look and give it some testing
myself.

