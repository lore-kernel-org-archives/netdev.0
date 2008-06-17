From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
 available to userspace
Date: Tue, 17 Jun 2008 13:47:12 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0806171344370.25191@shark.he.net>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
 <200806150158.28488.tomasz@grobelny.oswiecenia.net>
 <20080617111638.GA14409@gerrit.erg.abdn.ac.uk> <200806172228.06801.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>, acme@redhat.com,
	mtk.manpages@gmail.com, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:43796 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754260AbYFQUrP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 16:47:15 -0400
Received: from shark.he.net ([66.160.160.2]) by xenotime.net for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 13:47:12 -0700
In-Reply-To: <200806172228.06801.tomasz@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Jun 2008, Tomasz Grobelny wrote:

> Dnia Tuesday 17 of June 2008, Gerrit Renker napisa?:
> > | In other words the basic question is: do we want to add new parameters to
> > | existing qpolicies (then we need parameter discovery) or we don't want
> > | new parameters (then we don't need information about parameters available
> > | at runtime).
> > |
> > | Having defined the alternatives it's time to decide which is better. I,
> > | of course, claim that mine (which is adding new parameters to existing
> > | qpolicies). That's simply because I think that providing both
> > | DCCP_SCM_TIMEOUT and DCCP_SCM_PRIORITY parameters may be useful. And I
> > | don't see an obvoius way of achieving that goal with "new policy for new
> > | parameter" approach.
> >
> > I agree that providing both parameters may be useful, but don't see this
> > as a place of contradiction.
> >
> > In the kernel I think it is best to make it type-safe, i.e. no new
> > parameters to already-defined policies. But I can't see how this would
> > restrict the use.
> > (...)
> >
> So we would need new policy for each new parameter, right? I somehow don't 
> like it but it should work. You are right that this way runtime parameter 
> discovery is not necessary. BTW, we will have a bit of a problem with naming 
> qpolicies ;-)
> 
> > | > With a manpage I mean to document
> > |
> > | Is there any "man dccp"?
> >
> > Not yet. If you or someone else can find time to contribute towards a DCCP
> > manpage, that would be just great. The best available information so far is
> > on the OSDL pages for DCCP and Documentation/networking/dccp.txt.
> >
> But it's not in kernel sources? Then probably a new page would not be accepted 
> as it would describe an experimental API. The above mentioned dccp.txt is 
> probably the best place for now.
> 
> > I think there is a special maintainer for the kernel manpages, who could
> > be emailed with a basic manpage. But ther ere is a similar problem - if the
> > API changes frequently, then this requires to update the manpage
> > accordingly.

Michael's contact info is at http://kernel.org/doc/man-pages/ .

> I guess these would mostly be API additions, without any incompatible changes.
> 
> > As alternatives to documentation, there are for example providing
> >  *running source code,
> I will for sure be working on some apps to demonstrate how the new interface 
> can be used. But first I need to create a simple server/client transmitting 
> G.726 encoded voice over UDP/RTP (any hints on that?)...
> 
> >  * web pages or
> Is there any official, publicly editable DCCP wiki? I'd rather not create yet 
> another page...

The Linux Foundation wiki is probably as close to official as it gets.

  http://www.linuxfoundation.org/en/Net:Main_Page

-- 
~Randy
