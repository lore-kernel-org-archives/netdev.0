From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] netlink: connector: implement cn_netlink_reply
Date: Thu, 10 May 2012 20:22:25 +0100
Message-ID: <1336677745.2874.18.camel@bwh-desktop.uk.solarflarecom.com>
References: <1336574243-12063-1-git-send-email-alban.crequy@collabora.co.uk>
	 <1336609248.2499.20.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120510004553.GB8362@ioremap.net>
	 <20120510113908.5b79c5f3@chocolatine.cbg.collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>, <netdev@vger.kernel.org>,
	Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	Rodrigo Moya <rodrigo.moya@collabora.co.uk>
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:46691 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754998Ab2EJTWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 15:22:33 -0400
In-Reply-To: <20120510113908.5b79c5f3@chocolatine.cbg.collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-10 at 11:39 +0100, Alban Crequy wrote:
> On Thu, 10 May 2012 04:45:53 +0400,
> Evgeniy Polyakov <zbr@ioremap.net> wrote :
> 
> > On Thu, May 10, 2012 at 01:20:48AM +0100, Ben Hutchings
> > (bhutchings@solarflare.com) wrote:
> > > On Wed, 2012-05-09 at 15:37 +0100, Alban Crequy wrote:
> > > > In a connector callback, it was not possible to reply to a
> > > > message only to a sender. This patch implements
> > > > cn_netlink_reply(). It uses the connector socket to send an
> > > > unicast netlink message back to the sender.
> > > [...]
> > > 
> > > We try to avoid adding functions with no users.  You'll need to
> > > submit the code that's intended to use this as well.
> > 
> > I have no objection against this patch, but as correctly stated it is
> > useless without users. Alban, what is the code you want this
> > functionality to be used in? Do you plan to submit it? Can you submit
> > this change in the patch with your code?
> 
> The code to use the feature is not yet ready for submission and we will
> add this patch to the front of that submission in due course.
> 
> We are just being good community members and making each patch
> available early.

When you send a message with a subject beginning [PATCH] to a kernel
mailing list, it's generally assumed to be a request to the relevant
maintainer to apply that patch.  But kernel API functions are added only
to support features that are exposed exernally, and tend to be removed
when there are no in-tree users.

You could of course send such patches as RFCs ([RFC][PATCH] in the
subject), so it's clear that you don't expect them to be applied yet.

Ben.

> Thanks for your feedback on this patch. Please let
> me know if I can add any reviewed-by.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
