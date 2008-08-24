From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Sun, 24 Aug 2008 21:59:14 +0200
Message-ID: <20080824195914.GA3461@ami.dom.local>
References: <20080822221913.GA2981@ami.dom.local> <20080822.173348.232018958.davem@davemloft.net> <20080823084715.GA2515@ami.dom.local> <5f2db9d90808230931n453a3b75q84153dd8c18bcfc2@mail.gmail.com> <1219510193.4732.26.camel@localhost> <5f2db9d90808231209i134a7afbu233269c8ea592422@mail.gmail.com> <20080824075331.GA2721@ami.dom.local> <1219585163.4698.43.camel@localhost> <20080824191905.GA3372@ami.dom.local> <20080824192734.GB3372@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:24089 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884AbYHXTxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2008 15:53:10 -0400
Received: by ey-out-2122.google.com with SMTP id 6so132915eyi.37
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2008 12:53:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080824192734.GB3372@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 24, 2008 at 09:27:34PM +0200, Jarek Poplawski wrote:
> On Sun, Aug 24, 2008 at 09:19:05PM +0200, Jarek Poplawski wrote:
> ...
> > Jamal, maybe I miss something, but this could be like this only with
> > default pfifo_fast qdiscs, which really are per dev hwqueue. Other
> > qdiscs, including prio, are per device, so with prio, if a band with
> > the highest priority is blocked it would be requeued blocking other
> > bands (hwqueues in Alexander's case).
> 
> And, actually, because of this, Alexander is right the prio_dequeue()
> can't work like this without any changes.

...And it looks like it's not only about prio with queue remapping.
Similar fixes are probably needed by default to any other qdiscs
implementing priorities, like htb etc!

Jarek P.
