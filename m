From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 1/2] genetlink: introduce pre_doit/post_doit hooks
Date: Fri, 01 Oct 2010 00:44:50 +0200
Message-ID: <1285886690.5137.28.camel@jlt3.sipsolutions.net>
References: <20100930211013.472957770@sipsolutions.net>
	 <20100930211131.021309930@sipsolutions.net>
	 <AANLkTik9+zA4PPPx=q6CRM-sgOjjECJdtJTgkCG9pGAY@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	tgraf@suug.ch
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:39376 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756775Ab0I3WoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 18:44:15 -0400
In-Reply-To: <AANLkTik9+zA4PPPx=q6CRM-sgOjjECJdtJTgkCG9pGAY@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-10-01 at 08:41 +1000, Julian Calaby wrote:

> >  d) include two private pointers in each info
> >    struct passed between all these operations
> >    including doit(). (It's two because I'll
> >    need two in nl80211 -- can be extended.)
> 
> Stupid question:
> 
> Why not have a priv struct rather than an arbitrary array of two pointers?

It'd have to be dynamically allocated, and the "arbitrary" array of two
pointers can be on the stack.

johannes

