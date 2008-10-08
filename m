From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Possible regression in HTB
Date: Wed, 8 Oct 2008 07:53:46 +0000
Message-ID: <20081008075346.GD4174@ff.dom.local>
References: <20081007011551.GA28408@verge.net.au> <20081007045145.GA23883@verge.net.au> <20081007074435.GA2700@ff.dom.local> <20081008000928.GJ12021@verge.net.au> <20081008063701.GA4174@ff.dom.local> <20081008072243.GK22396@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:29998 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210AbYJHHxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 03:53:51 -0400
Received: by ug-out-1314.google.com with SMTP id k3so488577ugf.37
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2008 00:53:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081008072243.GK22396@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 08, 2008 at 06:22:44PM +1100, Simon Horman wrote:
> On Wed, Oct 08, 2008 at 06:37:01AM +0000, Jarek Poplawski wrote:
> > On Wed, Oct 08, 2008 at 11:09:28AM +1100, Simon Horman wrote:
> > > On Tue, Oct 07, 2008 at 07:44:35AM +0000, Jarek Poplawski wrote:
> > ...
> > > > So, thanks for testing and reporting this. (BTW, what network card
> > > > do you use and is there multiqueuing on?)
> > > 
> > > The network card is an e1000. Acutally there are two, but I
...
> > I've only wandered if we should consider any new effects because of
> > this, but e1000/1000e don't have this yet (bnx2 has).
...
> Ok, what should I be checking for?

I think, it's all with this... We simply know multiquing doesn't
matter here.

Jarek P. 
