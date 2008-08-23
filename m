From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Fri, 22 Aug 2008 17:33:48 -0700 (PDT)
Message-ID: <20080822.173348.232018958.davem@davemloft.net>
References: <1219415417.4672.79.camel@localhost>
	<20080822221913.GA2981@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37812
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754063AbYHWAdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 20:33:50 -0400
In-Reply-To: <20080822221913.GA2981@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sat, 23 Aug 2008 00:19:13 +0200

> jamal wrote, On 08/22/2008 04:30 PM:
> ...
> > What we were solving at the time: #2. My view was to solve it with
> > minimal changes.
> > 
> > #1 and #2 are orthogonal. Yes, there is religion: Dave yours is #1.
> > Intels is #2; And there are a lot of people in intels camp because
> > they bill their customers based on qos of resources. The wire being one
> > such resource.
> 
> If we can guarentee that current, automatic steering gives always the
> best performance than David seems to be right. But I doubt it, and
> that's why I think such a simple, manual control could be useful.
> Especially if it doesn't add much overhead.

If we want queue selection in the packet scheduler, let's implement
it, but let's do so properly using classifiers and TC actions or a
ematch modules that can select the queue.

Then people can implement whatever policy they want, in completely
generic ways, and the kernel simply doesn't care.

The way this code worked was completely special purpose and ignored
the host of facilities and infrastructure we have for doing things
like this.

