From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Wed, 2 Sep 2009 13:11:43 -0500 (CDT)
Message-ID: <alpine.DEB.1.10.0909021310370.27987@V090114053VZO-1>
References: <20090902080921.GA4878@ff.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:51223 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750780AbZIBOMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 10:12:32 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 48FA582C7E3
	for <netdev@vger.kernel.org>; Wed,  2 Sep 2009 10:14:16 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id WfuvGQ3EJ55M for <netdev@vger.kernel.org>;
	Wed,  2 Sep 2009 10:14:11 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8B88F82C474
	for <netdev@vger.kernel.org>; Wed,  2 Sep 2009 10:14:11 -0400 (EDT)
In-Reply-To: <20090902080921.GA4878@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Sep 2009, Jarek Poplawski wrote:

> Then my humble suggestions would be to reserve more space for most of
> the columns to make it readable not only for scripts when more TX#,
> bytes, packets etc. Users of non-default qdiscs would also miss things
> like: q->ops->id, q->handle, and q->parent at least. Plus, as I
> mentioned earlier, q->qstats.qlen update with q->q.qlen (or using it
> directly) is needed.

Which of those are needed if we just want to focus on statistics? Next rev
will have q->q.len.

