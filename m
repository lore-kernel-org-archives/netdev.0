From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v4 0/2] ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to suppress creation of IP6 routes
Date: Thu, 16 Jan 2014 14:38:18 +0100
Message-ID: <20140116133818.GF7436@order.stressinduktion.org>
References: <1389227404-12586-1-git-send-email-thaller@redhat.com> <20140110.181030.2081631538801450145.davem@davemloft.net> <20140113153110.GA2499@minipsycho.orion> <20140115.135328.514671277431781958.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: jiri@resnulli.us, thaller@redhat.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42501 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190AbaAPNiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 08:38:20 -0500
Content-Disposition: inline
In-Reply-To: <20140115.135328.514671277431781958.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 01:53:28PM -0800, David Miller wrote:
> From: Jiri Pirko <jiri@resnulli.us>
> Date: Mon, 13 Jan 2014 16:31:10 +0100
> 
> > Sat, Jan 11, 2014 at 12:10:30AM CET, davem@davemloft.net wrote:
> >>From: Thomas Haller <thaller@redhat.com>
> >>Date: Thu,  9 Jan 2014 01:30:02 +0100
> >>
> >>> v1 -> v2: add a second commit, handling NOPREFIXROUTE in ip6_del_addr.
> >>> v2 -> v3: reword commit messages, code comments and some refactoring.
> >>> v3 -> v4: refactor, rename variables, add enum
> >>> 
> >>> Thomas Haller (2):
> >>>   ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to suppress creation of
> >>>     IP6 routes
> >>>   ipv6 addrconf: don't cleanup prefix route for IFA_F_NOPREFIXROUTE
> >>
> >>Series applied, thanks Thomas.
> > 
> > Hi Dave. Have you pushed this already? I can't see these patches in
> > net-next.
> 
> Sorry, I must have forgotten to push these changes out before I travelled
> on Saturday.
> 
> Please respin and resubmit and I'll make sure they get integrated properly.

Just fyi, I noticed at least one other patch missing from the repos:
http://patchwork.ozlabs.org/patch/308452/

Greetings,

  Hannes
