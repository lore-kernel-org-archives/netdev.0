From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Thu, 3 Sep 2009 13:03:37 -0500 (CDT)
Message-ID: <alpine.DEB.1.10.0909031302190.27903@V090114053VZO-1>
References: <20090902212708.GC3018@ami.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:36341 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754497AbZICOGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 10:06:19 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id EB25582C578
	for <netdev@vger.kernel.org>; Thu,  3 Sep 2009 10:08:01 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id mJ44BwOnRzcQ for <netdev@vger.kernel.org>;
	Thu,  3 Sep 2009 10:07:56 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A42F082C22F
	for <netdev@vger.kernel.org>; Thu,  3 Sep 2009 10:06:21 -0400 (EDT)
In-Reply-To: <20090902212708.GC3018@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Sep 2009, Jarek Poplawski wrote:

> Btw, Patrick's comments reminded me this is probably not what you want
> in case of non-default qdiscs: the root qdisc like prio will be
> repeated for each tx queue with the same stats. I guess you need to do
> here an additional query e.g. by comparing dev_queue->qdisc_sleeping
> with that of i = 0.

Hmmm.. Maybe I better leave it to the experts then.

