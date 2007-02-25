From: "Stephens, Allan" <allan.stephens@windriver.com>
Subject: RE: [tipc-discussion] [RFC: 2.6 patch] net/tipc/: possible cleanups
Date: Sat, 24 Feb 2007 16:19:19 -0800
Message-ID: <AF1602CB2550CE4381C0C75118A7856BA2ACC6@ala-mail02.corp.ad.wrs.com>
References: <20070223221657.GA10153@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jon Maloy" <jon.maloy@ericsson.com>, <per.liden@ericsson.com>,
	<netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<linux-kernel@vger.kernel.org>
To: "Christoph Hellwig" <hch@infradead.org>,
	"Adrian Bunk" <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:51471 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752321AbXBYFTa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Feb 2007 00:19:30 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20070223221657.GA10153@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just to clarify an apparent misunderstanding that has snuck into this
thread:

1) There are quite a few people/groups out there who are using TIPC's
socket API, so the protocol as a whole is being used and should remain
in the kernel.

2) There are portions of TIPC's native API which are intended for use by
driver programmers, but which are not being used by any code that is
currently in the kernel.  While removing these API's from TIPC will only
impact these "freeloaders", it has the potential to discourage future
programmers who *do* want to contribute their work to the kernel by
removing API's that are apparently necessary/useful when doing coding of
this sort.

Regards,
Al

> -----Original Message-----
> From: Christoph Hellwig [mailto:hch@infradead.org] 
> Sent: Friday, February 23, 2007 5:17 PM
> To: Adrian Bunk
> Cc: Jon Maloy; per.liden@ericsson.com; Stephens, Allan; 
> netdev@vger.kernel.org; 
> tipc-discussion@lists.sourceforge.net; linux-kernel@vger.kernel.org
> Subject: Re: [tipc-discussion] [RFC: 2.6 patch] net/tipc/: 
> possible cleanups
> 
> On Fri, Feb 23, 2007 at 07:06:12PM +0100, Adrian Bunk wrote:
> > > >My impression is that most of this might have users that are not 
> > > >yet submitted for inclusion in the kernel - one year 
> after TIPC was merged.
> > > > 
> > > >
> > > Not quite. The exported symbols belong to a public API 
> for driver  
> > >programmers.
> > > We know about several users of this API, and there will 
> be more, but 
> > >I  don't think  any of them are aspiring to have their code be 
> > >included in the kernel.
> > >...
> > 
> > Why not?
> > 
> > The goal is to get as many drivers as possible included in 
> the kernel.
> 
> If we don't have any planned in-tree users for tipc we should 
> simply drop tipc from the kernel entirely.  No point to make 
> our maintaince work harder for out of tree freeloaders.
> 
