From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 2/4 v2] net: Use sk_tx_queue_mapping for connected sockets
Date: Fri, 16 Oct 2009 21:17:10 +0530
Message-ID: <OFF47153C2.42E54782-ON65257651.005080BE-65257651.0056B757@in.ibm.com>
References: <20091016072107.24384.17358.sendpatchset@localhost.localdomain> <20091016072132.24384.38301.sendpatchset@localhost.localdomain> <4AD84188.7030804@gmail.com> <OFAE5CC975.C26B600E-ON65257651.00401683-65257651.004721BC@in.ibm.com> <4AD87E22.9040500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([59.145.155.5]:37712 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762082AbZJPPsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 11:48:25 -0400
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp05.in.ibm.com (8.14.3/8.13.1) with ESMTP id n9GFlXG4026231
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 21:17:33 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9GFlXY32727960
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 21:17:33 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9GFlW6I030633
	for <netdev@vger.kernel.org>; Sat, 17 Oct 2009 02:47:32 +1100
In-Reply-To: <4AD87E22.9040500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Eric Dumazet <eric.dumazet@gmail.com> wrote on 10/16/2009 07:37:30 PM:

> > I wait for tcp_v4_syn_recv_sock to finish and create a connection.
> > sk_setup_caps/__sk_dst_set are called for the new socket resulting
> > in sk_dst_cache getting set (I cannot set the cache till the
> > connection is finished and dst is set). I guess that means that I
> > will wait for another skb to come and the response will use skb_tx_hash
> > instead of using the rx recorded.
>
> Well, I see no relation between rx mapping and tx mapping currently.

You are suggesting an enhancement to assign the txq# at ack processing
using the skb->rx#. As you said it will help cards that are hashing the
rx# internally. I will try that separately after this patch.

> > Will this suffice, but if not, is it something I should handle or an
> > add-on patch should do instead?
> >
>
> Your patch is fine, I was only giving ideas for future patches :)

Thanks for the suggestions, I just wanted to make sure.

- KK

