From: Cong Wang <amwang@redhat.com>
Subject: Re: TCP delayed ACK heuristic
Date: Wed, 19 Dec 2012 14:54:39 +0800
Message-ID: <1355900079.6665.13.camel@cr0>
References: <2088500005.27728019.1355843484620.JavaMail.root@redhat.com>
	 <1355848224.9380.30.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Rick Jones <rick.jones2@hp.com>, Thomas Graf <tgraf@redhat.com>
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30258 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751110Ab2LSGy4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 01:54:56 -0500
In-Reply-To: <1355848224.9380.30.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-18 at 08:30 -0800, Eric Dumazet wrote:
>  
> 
> ACKS might also be delayed because of bidirectional traffic, and is more
> controlled by the application response time. TCP stack can not easily
> estimate it.

So we still need a knob?

> 
> If you focus on bulk receive, LRO/GRO should already lower number of
> ACKS to an acceptable level and without major disruption.

Indeed.

> 
> Stretch acks are not only the receiver concern, there are issues for the
> sender that you cannot always control/change.
> 
> I recommend reading RFC2525 2.13
> 

Very helpful information!

On the sender's side, it needs to "notify" the receiver not to send
stretch acks when it is in slow-start. But I think the receiver can
detect slow-start too on its own side (based one the window size?).

Thanks!
