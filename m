From: Grant Edwards <grant.b.edwards@gmail.com>
Subject: Re: Change in alloc_skb() behavior in 3.2+ kernels?
Date: Wed, 6 Jun 2012 19:01:40 +0000 (UTC)
Message-ID: <jqo9ej$ao4$1@dough.gmane.org>
References: <jqo7op$t6f$1@dough.gmane.org>
 <20120606.115130.1091814494251887552.davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:51199 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757960Ab2FFTFH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 15:05:07 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1ScLXT-0007rf-SP
	for netdev@vger.kernel.org; Wed, 06 Jun 2012 21:05:03 +0200
Received: from dsl.comtrol.com ([64.122.56.22])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 21:05:03 +0200
Received: from grant.b.edwards by dsl.comtrol.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 21:05:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-06-06, David Miller <davem@davemloft.net> wrote:
> From: Grant Edwards <grant.b.edwards@gmail.com>
> Date: Wed, 6 Jun 2012 18:32:57 +0000 (UTC)
>
>> The kernel module that's started failing fills the allocated sk_buff
>> until tailroom() indicates it is full and then sends it.  The problem
>> is that sending a packet with a length of 1850 won't work (it's a
>> MAC-layer Ethernet packet).
>
> The amount of tailroom an SKB has is implementation dependent.

Today, that's apparently the case, but that's not what the man page
for alloc_skb said when the code was written.

> It's incredibly poor form to rely upon it to determine whether a fully
> sized frame has been constructed or not.
>
> Please fix the code that does this.

That's what I'll do as soon as I can find a definition of what the API
for alloc_skb() actually _is_.  It has clearly changed in the past few
years.

-- 
Grant Edwards               grant.b.edwards        Yow! I'm also against
                                  at               BODY-SURFING!!
                              gmail.com            
