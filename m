From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3] netns: oops in ip[6]_frag_reasm incrementing stats
Date: Thu, 19 Mar 2009 14:56:49 -0700 (PDT)
Message-ID: <20090319.145649.51207208.davem@davemloft.net>
References: <20090318072658.GA4799@ff.dom.local>
	<20090318.232651.99085030.davem@davemloft.net>
	<20090319215428.GA2714@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jorge@dti2.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49353
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758872AbZCSV5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 17:57:03 -0400
In-Reply-To: <20090319215428.GA2714@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 19 Mar 2009 22:54:28 +0100

> On Wed, Mar 18, 2009 at 11:26:51PM -0700, David Miller wrote:
> > Netfilter on ipv6 handles reassembly differently and in a way
> > that won't result in dev being NULL here.
> > 
> > I've applied Jorge's patch, thanks everyone.
> 
> My proposal is to revert the ipv6/reassembly part of this patch yet;
> it doesn't fix anything, and the changelog is only misleading if it's
> like you said.

I've already pushed the change out to net-2.6 so I'd really prefer not
to do that.  Make your desires known more emphatically before a patch
has been sitting around for days.

At worst it's a consistency cleanup with an inaccurate commit message,
reverting will only make the situation more confusing and ugly.
