From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: Re: [PATCH net-next] net: sk_buff: memset(skb,0) after alloc in
 skb_clone
Date: Thu, 12 Sep 2013 11:51:18 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1309121149320.1735@gmail.com>
References: <1378788533-5609-1-git-send-email-govindarajulu90@gmail.com> <1378816832.26319.75.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Govindarajulu Varadarajan <govindarajulu90@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:42178 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752596Ab3ILGVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 02:21:23 -0400
Received: by mail-pb0-f49.google.com with SMTP id xb4so10049458pbc.36
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 23:21:22 -0700 (PDT)
In-Reply-To: <1378816832.26319.75.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 10 Sep 2013, Eric Dumazet wrote:

> On Tue, 2013-09-10 at 10:18 +0530, Govindarajulu Varadarajan wrote:
>> The following patch memset the skb to 0 after alloc. We do this in
>> __alloc_skb_head, __alloc_skb, build_skb. We are missing this in
>> skb_clone.
>>
>> The following call to __skb_clone in skb_clone does not copy all the
>> members of sk_buff. If we donot clear the skb to 0, we will have some
>> uninitialized members in new skb.
>
> Which ones exactly ?
>
> I would rather make sure all fields are properly copied.
>
> Your patch is incomplete, because it doesn't handle the fast clone case.

Sorry, my bad. Didnt check the __copy_skb_header completely.

thanks
//govind
