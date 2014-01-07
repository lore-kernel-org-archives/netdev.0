From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1] ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to suppress creation of IP6 routes
Date: Tue, 7 Jan 2014 13:22:03 +0100
Message-ID: <20140107122203.GC24730@order.stressinduktion.org>
References: <20140106160139.GB10204@order.stressinduktion.org> <1389029375-17698-1-git-send-email-thaller@redhat.com> <20140107120111.GB24730@order.stressinduktion.org> <1389096874.2248.7.camel@weing>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com
To: Thomas Haller <thaller@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44887 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbaAGMWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 07:22:05 -0500
Content-Disposition: inline
In-Reply-To: <1389096874.2248.7.camel@weing>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas!

On Tue, Jan 07, 2014 at 01:14:34PM +0100, Thomas Haller wrote:
> I am about to resent the patch, so that IFA_F_NOPREFIXROUTE is saved in
> the flags of the address. Later, when deleting such address, this is
> used to indicate ~not~ to delete any prefix route... just as you suggest
> in your earlier email (if I understood you right).

Ok, good.

> About this suggestion now, I tend to "no". Yes, it could be sensible, on
> the other hand, if user space already controls the routes (as indicated
> by it's use of IFA_F_NOPREFIXROUTES), I would just leave it to the user
> to clean up the wrong prefix route.
>
> What do you think?

It is a matter of usability. As prefix routes are added to main routing
table and are visible via simple ip -6 r l (and not ip -6 r l table
something), I am fine with that, too.

Greetings,

  Hannes
