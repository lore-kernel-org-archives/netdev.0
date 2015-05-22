From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix a potential deadlock in
 tcp_get_info()
Date: Fri, 22 May 2015 14:12:25 -0400 (EDT)
Message-ID: <20150522.141225.2230288569471785318.davem@davemloft.net>
References: <1432270279.4060.128.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150522.135042.1383929510137041615.davem@redhat.com>
	<1432317396.4060.130.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, edumazet@google.com, netdev@vger.kernel.org,
	ycheng@google.com, mattmathis@google.com, cgallek@google.com,
	kafai@fb.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49354 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757206AbbEVSM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 14:12:28 -0400
In-Reply-To: <1432317396.4060.130.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 22 May 2015 10:56:36 -0700

> On Fri, 2015-05-22 at 13:50 -0400, David Miller wrote:
> 
>> This bug exists in 'net' so I've applied it there.
>> 
>> Thanks Eric.
> 
> Oh thats right, sorry for this, as you'll probably have a conflict when
> merging net into net-next.

I know, but thanks for the heads up.
