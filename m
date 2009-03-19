From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCHv3] netns: oops in ip[6]_frag_reasm incrementing stats
Date: Thu, 19 Mar 2009 23:09:27 +0100
Message-ID: <20090319220927.GB2714@ami.dom.local>
References: <20090318072658.GA4799@ff.dom.local> <20090318.232651.99085030.davem@davemloft.net> <20090319215428.GA2714@ami.dom.local> <20090319.145649.51207208.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jorge@dti2.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:47197 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756374AbZCSWKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 18:10:43 -0400
Received: by fxm2 with SMTP id 2so696318fxm.37
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2009 15:10:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090319.145649.51207208.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2009 at 02:56:49PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Thu, 19 Mar 2009 22:54:28 +0100
> 
> > On Wed, Mar 18, 2009 at 11:26:51PM -0700, David Miller wrote:
> > > Netfilter on ipv6 handles reassembly differently and in a way
> > > that won't result in dev being NULL here.
> > > 
> > > I've applied Jorge's patch, thanks everyone.
> > 
> > My proposal is to revert the ipv6/reassembly part of this patch yet;
> > it doesn't fix anything, and the changelog is only misleading if it's
> > like you said.
> 
> I've already pushed the change out to net-2.6 so I'd really prefer not
> to do that.  Make your desires known more emphatically before a patch
> has been sitting around for days.

I guess you should re-read the thread: if not me, the author of this
patch was very emphatical...

> 
> At worst it's a consistency cleanup with an inaccurate commit message,
> reverting will only make the situation more confusing and ugly.

Sure, no big deal.

Jarek P.
