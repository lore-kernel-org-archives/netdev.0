From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Sat, 23 Aug 2008 10:47:15 +0200
Message-ID: <20080823084715.GA2515@ami.dom.local>
References: <1219415417.4672.79.camel@localhost> <20080822221913.GA2981@ami.dom.local> <20080822.173348.232018958.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.234]:4250 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952AbYHWIqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 04:46:47 -0400
Received: by qb-out-0506.google.com with SMTP id a16so1094084qbd.17
        for <netdev@vger.kernel.org>; Sat, 23 Aug 2008 01:46:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080822.173348.232018958.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2008 at 05:33:48PM -0700, David Miller wrote:
...
> If we want queue selection in the packet scheduler, let's implement
> it, but let's do so properly using classifiers and TC actions or a
> ematch modules that can select the queue.
> 
> Then people can implement whatever policy they want, in completely
> generic ways, and the kernel simply doesn't care.
> 
> The way this code worked was completely special purpose and ignored
> the host of facilities and infrastructure we have for doing things
> like this.

Alas I can't get your point here. prio is sched + classifier 2 in 1,
and if a small change in this is enough for somebody who really uses
this, and there seem to be noone interested in doing this better or
harmed with this, why bother with actions or other classifiers? Maybe
this prio method is less generic, but it's quite simple and there is
some infrastructure around this.

Jarek P.
