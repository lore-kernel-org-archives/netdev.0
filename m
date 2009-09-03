From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Thu, 3 Sep 2009 21:35:55 +0200
Message-ID: <20090903193555.GA3138@ami.dom.local>
References: <20090902212708.GC3018@ami.dom.local>
 <alpine.DEB.1.10.0909031302190.27903@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:61582 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756088AbZICTgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 15:36:13 -0400
Received: by fxm17 with SMTP id 17so198761fxm.37
        for <netdev@vger.kernel.org>; Thu, 03 Sep 2009 12:36:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0909031302190.27903@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 03, 2009 at 01:03:37PM -0500, Christoph Lameter wrote:
> On Wed, 2 Sep 2009, Jarek Poplawski wrote:
> 
> > Btw, Patrick's comments reminded me this is probably not what you want
> > in case of non-default qdiscs: the root qdisc like prio will be
> > repeated for each tx queue with the same stats. I guess you need to do
> > here an additional query e.g. by comparing dev_queue->qdisc_sleeping
> > with that of i = 0.
> 
> Hmmm.. Maybe I better leave it to the experts then.
> 

This is certainly not what I wanted... The experts missed this problem
long enough. It might only need to wait a bit for Patrick's changes.

Jarek P.
