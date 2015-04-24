From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next 1/3] ipvlan: Defer multicast / broadcast
 processing to a work-queue
Date: Fri, 24 Apr 2015 00:28:36 -0400 (EDT)
Message-ID: <20150424.002836.1182213850465198590.davem@davemloft.net>
References: <1429824589-23663-1-git-send-email-maheshb@google.com>
	<1429835549.22254.105.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAF2d9jgBwgLzg3y9KDaVHmbE7_NYnHVjTPfD=Jw-yAbLGGhe7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	edumazet@google.com, dcbw@redhat.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46818 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbbDXE2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 00:28:51 -0400
In-Reply-To: <CAF2d9jgBwgLzg3y9KDaVHmbE7_NYnHVjTPfD=Jw-yAbLGGhe7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Thu, 23 Apr 2015 19:54:29 -0700

> On Thu, Apr 23, 2015 at 5:32 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Thu, 2015-04-23 at 14:29 -0700, Mahesh Bandewar wrote:
>>
>>> +static void ipvlan_multicast_enqueue(struct ipvl_port *port,
>>> +                                  struct sk_buff *skb)
>>> +{
>>> +     if (skb->protocol == htons(ETH_P_PAUSE))
>>> +             return;
>>
>> But what happens to this packet ? It seems leaked ?
>>
> Hmm, will take care of it in v2.

Please also provide a proper "[PATCH 0/3] " introduction posting
stating what the patch series is doing, and why.

Thanks.
