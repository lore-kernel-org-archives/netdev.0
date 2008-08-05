From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take 2] net_sched: Add qdisc __NET_XMIT_BYPASS flag
Date: Tue, 05 Aug 2008 14:22:55 -0700 (PDT)
Message-ID: <20080805.142255.05371666.davem@davemloft.net>
References: <20080804213535.14214iqhxkx3v3so@hayate.ip6>
	<20080804210333.GA2849@ami.dom.local>
	<20080805154350.27523juch31xgjcw@hayate.ip6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, kaber@trash.net, netdev@vger.kernel.org
To: jussi.kivilinna@mbnet.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35135
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765053AbYHEVWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 17:22:55 -0400
In-Reply-To: <20080805154350.27523juch31xgjcw@hayate.ip6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Date: Tue, 05 Aug 2008 15:43:50 +0300

> Quoting "Jarek Poplawski" <jarkao2@gmail.com>:
> 
> > On Mon, Aug 04, 2008 at 09:35:35PM +0300, Jussi Kivilinna wrote:
> >> Quoting "Jarek Poplawski" <jarkao2@gmail.com>:
> >>
> >> This seems to also make sure that when returning 'full'
> >> NET_XMIT_SUCCESS, skb pointer is safe(r?) to use now.
> >
> > I guess so... At least theoretically - I was mainly afraid of
> > redirecting, which isn't fully implemented yet. On the other hand,
> > outwards of qdiscs there is still no difference.
> >
> 
> How about making skb shared before passing into qdisc tree?
> That would make skb usage safe after qdisc enqueues.

That's two extra atomic operations on every transmitted packet,
no thanks :-)
