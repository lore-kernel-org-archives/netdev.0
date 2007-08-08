From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in IPoIB
Date: Wed, 8 Aug 2007 16:39:47 +0530
Message-ID: <OF09D78F6D.0A3EBAD3-ON65257331.003CB0E9-65257331.003D526B@in.ibm.com>
References: <20070808.034900.85820906.davem@davemloft.net>
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
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:61366 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751936AbXHHLMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 07:12:44 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l78BEnoL252176
	for <netdev@vger.kernel.org>; Wed, 8 Aug 2007 21:14:55 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l78BDuNW118358
	for <netdev@vger.kernel.org>; Wed, 8 Aug 2007 21:13:57 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l78BALXc012442
	for <netdev@vger.kernel.org>; Wed, 8 Aug 2007 21:10:23 +1000
In-Reply-To: <20070808.034900.85820906.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote on 08/08/2007 04:19:00 PM:

> From: Krishna Kumar <krkumar2@in.ibm.com>
> Date: Wed, 08 Aug 2007 15:01:14 +0530
>
> > RESULTS: The performance improvement for TCP No Delay is in the range
of -8%
> >    to 320% (with -8% being the sole negative), with many individual
tests
> >    giving 50% or more improvement (I think it is to do with the hw
slots
> >    getting full quicker resulting in more batching when the queue gets
> >    woken). The results for TCP is in the range of -11% to 93%, with
most
> >    of the tests (8/12) giving improvements.
>
> Not because I think it obviates your work, but rather because I'm
> curious, could you test a TSO-in-hardware driver converted to
> batching and see how TSO alone compares to batching for a pure
> TCP workload?
>
> I personally don't think it will help for that case at all as
> TSO likely does better job of coalescing the work _and_ reducing
> bus traffic as well as work in the TCP stack.

Definitely, I will try to do this.

What do you generally think of the patch/implementation ? :)

thanks,

- KK

