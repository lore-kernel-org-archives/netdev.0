From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9] net: Pass a "more" indication down into
 netdev_start_xmit() code paths.
Date: Mon, 01 Sep 2014 18:41:20 -0700 (PDT)
Message-ID: <20140901.184120.1624854380814529841.davem@davemloft.net>
References: <20140901.152454.408917069371597628.davem@davemloft.net>
	<CA+mtBx-jOW1CrasHkivcoECCzAnBJ7h6Vui4j+2SrUaVCvAc-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46073 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbaIBBlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 21:41:21 -0400
In-Reply-To: <CA+mtBx-jOW1CrasHkivcoECCzAnBJ7h6Vui4j+2SrUaVCvAc-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 1 Sep 2014 18:21:57 -0700

> On Mon, Sep 1, 2014 at 3:24 PM, David Miller <davem@davemloft.net> wrote:
>> +                                             bool more)
>>  {
>> -       skb->xmit_more = 0;
>> +       skb->xmit_more = more ? 1 : 0;
> 
> Maybe just
> 
> skb->xmit_more = more;

I'm just being overly cautious because we're storing a boolean into
an integer bitfield.
