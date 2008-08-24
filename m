From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Sun, 24 Aug 2008 21:19:05 +0200
Message-ID: <20080824191905.GA3372@ami.dom.local>
References: <1219415417.4672.79.camel@localhost> <20080822221913.GA2981@ami.dom.local> <20080822.173348.232018958.davem@davemloft.net> <20080823084715.GA2515@ami.dom.local> <5f2db9d90808230931n453a3b75q84153dd8c18bcfc2@mail.gmail.com> <1219510193.4732.26.camel@localhost> <5f2db9d90808231209i134a7afbu233269c8ea592422@mail.gmail.com> <20080824075331.GA2721@ami.dom.local> <1219585163.4698.43.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:33821 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678AbYHXTNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2008 15:13:19 -0400
Received: by nf-out-0910.google.com with SMTP id d3so589087nfc.21
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2008 12:13:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1219585163.4698.43.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 24, 2008 at 09:39:23AM -0400, jamal wrote:
...
> With current controls being per qdisc instead of per netdevice,
> the hol fear is unfounded. 
> You send and when hw cant keep up, you block just the one hwqueue.
> While hwqueue is blocked, you can accumulate packets in the prio qdisc
> (hence my statement it may not be necessary to accumulate packets in
> driver).

Jamal, maybe I miss something, but this could be like this only with
default pfifo_fast qdiscs, which really are per dev hwqueue. Other
qdiscs, including prio, are per device, so with prio, if a band with
the highest priority is blocked it would be requeued blocking other
bands (hwqueues in Alexander's case).

Cheers,
Jarek P.
