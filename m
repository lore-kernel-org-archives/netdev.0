From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] qdisc: exit case fixes for skb list handling
 in qdisc layer
Date: Thu, 04 Sep 2014 22:41:55 -0700 (PDT)
Message-ID: <20140904.224155.345294600116542200.davem@davemloft.net>
References: <20140903.204256.1398300065789241714.davem@davemloft.net>
	<1409808259.26422.84.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140904073912.6767fc20@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, fw@strlen.de,
	hannes@stressinduktion.org, dborkman@redhat.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45074 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbaIEFl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 01:41:57 -0400
In-Reply-To: <20140904073912.6767fc20@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 4 Sep 2014 07:39:12 +0200

> On Wed, 03 Sep 2014 22:24:19 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> On Wed, 2014-09-03 at 20:42 -0700, David Miller wrote:
>> > From: Jesper Dangaard Brouer <brouer@redhat.com>
>> > Date: Wed, 03 Sep 2014 12:12:50 +0200
>> > 
>> > > More minor fixes to merge commit 53fda7f7f9e (Merge branch 'xmit_list')
>> > > that allows us to work with a list of SKBs.
>> > > 
>> > > Fixing exit cases in qdisc_reset() and qdisc_destroy(), where a
>> > > leftover requeued SKB (qdisc->gso_skb) can have the potential of
>> > > being a skb list, thus use kfree_skb_list().
>> > > 
>> > > This is a followup to commit 10770bc2d1 ("qdisc: adjustments for
>> > > API allowing skb list xmits").
>> > > 
>> > > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>> > 
>> > Applied.
>> 
>> Strange, I sent same patch a little earlier ;)
> 
> Yes, very strange, especially as Dave also said he had applied your
> patch too (I did comment on your post, apologizing for not noticing
> your patch, before sending this one).

This is my fault.

I put Eric's copy into my GIT tree on my workstation at home, build
tested it, but did not push it out.

Then I did GIT work from my laptop for the following two days. :-/

Sorry about that.
