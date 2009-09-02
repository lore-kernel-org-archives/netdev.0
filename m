From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Wed, 2 Sep 2009 21:33:37 +0200
Message-ID: <20090902193337.GA3018@ami.dom.local>
References: <20090902080921.GA4878@ff.dom.local>
 <alpine.DEB.1.10.0909021310370.27987@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:37347 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616AbZIBTds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 15:33:48 -0400
Received: by bwz19 with SMTP id 19so977767bwz.37
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2009 12:33:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0909021310370.27987@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 02, 2009 at 01:11:43PM -0500, Christoph Lameter wrote:
> On Wed, 2 Sep 2009, Jarek Poplawski wrote:
> 
> > Then my humble suggestions would be to reserve more space for most of
> > the columns to make it readable not only for scripts when more TX#,
> > bytes, packets etc. Users of non-default qdiscs would also miss things
> > like: q->ops->id, q->handle, and q->parent at least. Plus, as I
> > mentioned earlier, q->qstats.qlen update with q->q.qlen (or using it
> > directly) is needed.
> 
> Which of those are needed if we just want to focus on statistics? Next rev
> will have q->q.len.

IMHO in the future there will be included most of the current tc qdisc
stats items. It would be nice to avoid those backward compatibility
arguments in the meantime as much as we can. But of course I might be
wrong, so feel free to do it your way.

Jarek P.
