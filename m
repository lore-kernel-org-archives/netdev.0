From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 2/3] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Wed, 3 Sep 2014 14:27:14 +0200
Message-ID: <20140903142714.240967bd@redhat.com>
References: <20140902143254.1918.8419.stgit@dragon>
	<20140902143538.1918.82870.stgit@dragon>
	<5405ECEC.601@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	brouer@redhat.com
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37019 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932091AbaICM1c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 08:27:32 -0400
In-Reply-To: <5405ECEC.601@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 02 Sep 2014 18:14:36 +0200
Daniel Borkmann <dborkman@redhat.com> wrote:

> On 09/02/2014 04:35 PM, Jesper Dangaard Brouer wrote:
>
> > This patch implements qdisc bulk dequeue, by allowing multiple packets
> > to be dequeued in dequeue_skb().
> >
[...]
 
> This check should better be an inline for sch_generic.h, e.g. ...
> 
> static inline bool qdisc_may_bulk(const struct Qdisc *qdisc,
> 				  const struct sk_buff *skb)
> {
> 	return (qdisc->flags & TCQ_F_ONETXQUEUE) && !skb->next;
> }

Good ideas of inlining these functions, it should help readability of
the code, thanks.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
