From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Speed-up pfifo_fast lookup using a bitmap
Date: Thu, 13 Aug 2009 11:27:16 +0000
Message-ID: <20090813112715.GA7010@ff.dom.local>
References: <20090813072818.7541.77365.sendpatchset@localhost.localdomain> <20090813100826.GA6042@ff.dom.local> <OFD762AF41.E7A6EE8D-ON65257611.00389F3C-65257611.003AC5BB@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, herbert@gondor.apana.org.au, kaber@trash.net,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f228.google.com ([209.85.220.228]:32791 "EHLO
	mail-fx0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753082AbZHML1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 07:27:21 -0400
Content-Disposition: inline
In-Reply-To: <OFD762AF41.E7A6EE8D-ON65257611.00389F3C-65257611.003AC5BB@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 13, 2009 at 04:11:57PM +0530, Krishna Kumar2 wrote:
> > Jarek Poplawski <jarkao2@gmail.com>
> >
> > > but the test numbers came a little less, since it takes a few more
> > > memory references on enqueue/dequeue.
> >
> > If it's exactly "a little less" I'd consider keeping it private yet...
> 
> Sounds reasonable. To quantify that, I will test again for a longer
> run and report the difference.

Yes, more numbers would be appreciated.

> 
> > Btw, I wonder how much gain of your previous (_CAN_BYPASS) patch is
> > saved after this change...
> 
> The tests are on the latest tree which contains CAN_BYPASS. So a
> single netperf process running this change will get no advantage
> since this enqueue/dequeue never happens unless the NIC is slow.
> But for multiple processes, it should help.

I mean: since the previous patch saved ~2% on omitting enqueue/dequeue,
and now enqueue/dequeue is ~2% faster, is it still worth to omit this?

Regards,
Jarek P.
