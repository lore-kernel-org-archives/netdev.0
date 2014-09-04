From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC net-next PATCH V2 2/3] qdisc: bulk dequeue support for
 qdiscs with TCQ_F_ONETXQUEUE
Date: Thu, 4 Sep 2014 10:09:14 -0700
Message-ID: <CAHA+R7PBM8Gxf1kb-FLBCbdH+VVyJ9kQs84RhLKLb-RFOTjR_w@mail.gmail.com>
References: <20140904125247.4108.8132.stgit@dragon>
	<20140904125438.4108.38160.stgit@dragon>
	<20140904131702.GA934@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:52425 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbaIDRJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 13:09:15 -0400
Received: by mail-lb0-f170.google.com with SMTP id w7so12012829lbi.15
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 10:09:14 -0700 (PDT)
In-Reply-To: <20140904131702.GA934@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 4, 2014 at 6:17 AM, Florian Westphal <fw@strlen.de> wrote:
>
> Unrelated to your patch: q->gso_skb should be renamed.
> It has nothing to do with gso anymore...
>

I have a pending patch which renames it to ->dequeued_skb.
