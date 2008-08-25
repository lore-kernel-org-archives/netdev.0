From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Mon, 25 Aug 2008 09:36:32 +0000
Message-ID: <20080825093632.GA3606@ff.dom.local>
References: <1219585163.4698.43.camel@localhost> <20080824191905.GA3372@ami.dom.local> <20080824192734.GB3372@ami.dom.local> <20080824.175026.237775292.davem@davemloft.net> <5f2db9d90808242003p5e4e1946rebf3a9b3945c7c51@mail.gmail.com> <20080825061628.GB2633@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:1552 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753828AbYHYJgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 05:36:40 -0400
Received: by nf-out-0910.google.com with SMTP id d3so698153nfc.21
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2008 02:36:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080825061628.GB2633@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 25, 2008 at 06:16:28AM +0000, Jarek Poplawski wrote:
> On Sun, Aug 24, 2008 at 08:03:11PM -0700, Alexander Duyck wrote:
...
> > What I am planning to implement at this point is a simple multi-band
> > qdisc that assigns the band number based on queue mapping.  This
> > combined with something like the rr_dequeue from the original qdisc
> > will resolve the head-of-line issues.  Essentially it will try to
> > mimic the way the pfifo_fast qdiscs work with hardware multiqueue, but
> > it will have the ability to classify traffic and be stuck with one
> > spin lock for all queues.
...
> I agree with you that a separate qdisc, or actually some aliases, like
> this older sch_rr, and maybe also independent sch_prio_mq with .enqueue
> and .dequeue overridden, look most sensible to me.

On the other hand, if these new qdiscs don't even need prio_classify(),
making it standalone looks better.

Jarek P.
