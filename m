From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Possible regression in HTB
Date: Fri, 10 Oct 2008 12:12:21 +0000
Message-ID: <20081010121221.GB6494@ff.dom.local>
References: <20081007220022.GA2664@ami.dom.local> <20081010065934.GA4762@ff.dom.local> <20081010085735.GA5946@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Martin Devera <devik@cdi.cz>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.189]:25770 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753053AbYJJMM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 08:12:28 -0400
Received: by fk-out-0910.google.com with SMTP id 18so420736fkq.5
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2008 05:12:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081010085735.GA5946@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 10, 2008 at 08:57:35AM +0000, Jarek Poplawski wrote:
> On Fri, Oct 10, 2008 at 06:59:34AM +0000, Jarek Poplawski wrote:
> ...
> > But we could consider if, after removing requeuing which mattered
> > here, some change is needed in "proper" way of limiting such effects
> > of wrong parameters or hardware errors (like the size of mbuffer etc.)?
> 
> Simon,
> 
> If you could find "a minute", please try if this patch changes anything
> e.g. for n = 1000?

Hmm... this mbuffer change is not enough, let's forget it.

Jarek P.
