From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: Re: [PATCH V3 net-next 1/3] ipv6: add the IPV6_FL_F_REFLECT flag
 to IPV6_FL_A_GET
Date: Fri, 17 Jan 2014 16:18:52 +0100
Message-ID: <52D949DC.40407@enst-bretagne.fr>
References: <1389889158-1710-1-git-send-email-florent.fourcot@enst-bretagne.fr> <20140117012722.GA24345@order.stressinduktion.org> <52D91F37.8060602@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:34806 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752778AbaAQPSz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 10:18:55 -0500
In-Reply-To: <52D91F37.8060602@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>>
>> I am not sure here, do you write the flow_label on the listening socket?
>>
> 
> Hum, yes. You are right, this is bad.
> 
> One alternative is not so simple. Perhaps could we store the flowlabel
> in inet_request_sock? It will be available in the tcp_v6_send_synack
> function, even in case of retransmission.


Ok, it is possible to use ireq->pktopts, without adding any memory
overhead for other users. I will send a V4.

Thanks Hannes,

Florent.
