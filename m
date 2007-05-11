From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 10:51:58 +0530
Message-ID: <OFF54241AB.D15580EE-ON652572D8.001D01CA-652572D8.001D7A43@in.ibm.com>
References: <20070510.133710.15264671.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: gaagaan@gmail.com, johnpol@2ka.mipt.ru, netdev@vger.kernel.org,
	rick.jones2@hp.com, sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:39101 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754308AbXEKFXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 01:23:03 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4B5gjNf264408
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 15:42:46 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4B5QRw8108504
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 15:26:29 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4B5Mnm8031319
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 15:22:50 +1000
In-Reply-To: <20070510.133710.15264671.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote on 05/11/2007 02:07:10 AM:

> From: Gagan Arneja <gaagaan@gmail.com>
> Date: Thu, 10 May 2007 12:43:53 -0700
> >
> > Also, I think, you don't have to chain skbs, they're already chained in

> >   Qdisc->q. All you have to do is take the whole q and try to shove it
> > at the device hoping for better results. But then, if you have rather
> > big backlog, you run the risk of reordering packets if you have to
requeue.
>
> If the qdisc is packed with packets and we would just loop sending
> them to the device, yes it might make sense.
>
> But if that isn't the case, which frankly is the usual case, you add a
> non-trivial amount of latency by batching and that's bad exactly for
> the kind of applications that send small frames.

Without batching, the latency should be the same since qdisc_run would
send each in a tight loop ?

I will also run TCP/UDP RR tests.

thanks,

- KK

