From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in IPoIB
Date: Wed, 22 Aug 2007 12:33:04 +0530
Message-ID: <OF6B96E612.D20F2F6A-ON6525733F.0025E38A-6525733F.0026BBB8@in.ibm.com>
References: <20070821.212229.82050253.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: gaagaan@gmail.com, general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, kumarkr@linux.ibm.com,
	mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:50665 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753075AbXHVHDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 03:03:42 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l7M76ae3165332
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 17:06:45 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7M76KjL176942
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 17:06:21 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7M72iYD018420
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 17:02:46 +1000
In-Reply-To: <20070821.212229.82050253.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

David Miller <davem@davemloft.net> wrote on 08/22/2007 09:52:29 AM:

> From: Krishna Kumar2 <krkumar2@in.ibm.com>
> Date: Wed, 22 Aug 2007 09:41:52 +0530
>
<snip>
> > > Because TSO does batching already, so it's a very good
> > > "tit for tat" comparison of the new batching scheme
> > > vs. an existing one.
> >
> > I am planning to do more testing on your suggestion over the
> > weekend, but I had a comment. Are you saying that TSO and
> > batching should be mutually exclusive so hardware that doesn't
> > support TSO (like IB) only would benefit?
> >
> > But even if they can co-exist, aren't cases like sending
> > multiple small skbs better handled with batching?
>
> I'm not making any suggestions, so don't read that into anything I've
> said :-)
>
> I think the jury is still out, but seeing TSO perform even slightly
> worse with the batching changes in place would be very worrysome.
> This applies to both throughput and cpu utilization.

Does turning off batching solve that problem? What I mean by that is:
batching can be disabled if a TSO device is worse for some cases. Infact
something that I had changed my latest code is to not enable batching
in register_netdevice (in Rev4 which I am sending in a few mins), rather
the user has to explicitly turn 'on' batching.

Wondering if that is what you are concerned about. In any case, I will
test your case on Monday (I am on vacation for next couple of days).

Thanks,

- KK

