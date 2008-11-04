From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/2] sch_netem: Remove classful functionality
Date: Tue, 4 Nov 2008 09:56:42 +0000
Message-ID: <20081104095642.GA4498@ff.dom.local>
References: <20081031132010.GA18895@ff.dom.local> <20081102.003700.198708146.davem@davemloft.net> <20081103082926.GA4698@ff.dom.local> <490EDE79.6070500@trash.net> <20081103090630.40b645d2@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:6228 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561AbYKDJ4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 04:56:48 -0500
Received: by nf-out-0910.google.com with SMTP id d3so1197478nfc.21
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2008 01:56:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081103090630.40b645d2@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 03, 2008 at 09:06:30AM -0800, Stephen Hemminger wrote:
> On Mon, 03 Nov 2008 12:20:25 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
> > Jarek Poplawski wrote:
> > > On Sun, Nov 02, 2008 at 12:37:00AM -0700, David Miller wrote:
> > >> From: Jarek Poplawski <jarkao2@gmail.com>
> > >> Date: Fri, 31 Oct 2008 13:20:10 +0000
> > >>
> > >> Jarek, I applied this patch and your second one to net-next-2.6
> > >>
> > >> But I did this only because I trust that you will address Stephen's
> > >> feedback wrt. making existing netem functionality available in
> > >> some way.
> > >>
> > >> Otherwise I'll have to revert these changes.
> > > 
> > > Hmm... I thought there was kind of RFC for this, and it looked like
> > > Patrick's idea won 100% of votes, but I'm not good in counting...
> > > 
> > > http://marc.info/?l=linux-netdev&m=122469801712438&w=2
> > > http://marc.info/?l=linux-netdev&m=122469674709761&w=2
> > > 
> > > Anyway, IMHO adding TBF etc. functionalities to tfifo doesn't make
> > > much sense, and if they are really needed it's better to revert
> > > these patches and chose one of the other ways of doing reorder
> > > proposed in this earlier thread.
> > 
> > Whats wrong with simply using TBF as parent qdisc of netem?
> 
> It works but does something slightly different.
> 
>    netem inside TBF is like long delay network followed by choke on last hop
>    TBF inside netem was like choke on uplink followed by long delay network.

David, this makes sense to me, so please revert these two patches.
(Then, I think we're still at RFC stage.)

Thanks.
Jarek P.
