From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v4 2/2] ipv6 addrconf: don't cleanup prefix route for IFA_F_NOPREFIXROUTE
Date: Fri, 10 Jan 2014 05:12:27 +0100
Message-ID: <20140110041227.GB1012@order.stressinduktion.org>
References: <20140108200019.GK9007@order.stressinduktion.org> <1389227404-12586-1-git-send-email-thaller@redhat.com> <1389227404-12586-3-git-send-email-thaller@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com
To: Thomas Haller <thaller@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53072 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbaAJEM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 23:12:28 -0500
Content-Disposition: inline
In-Reply-To: <1389227404-12586-3-git-send-email-thaller@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 09, 2014 at 01:30:04AM +0100, Thomas Haller wrote:
> Refactor the deletion/update of prefix routes when removing an
> address. Now also consider IFA_F_NOPREFIXROUTE and if there is an address
> present with this flag, to not cleanup the route. Instead, assume
> that userspace is taking care of this route.
> 
> Also perform the same cleanup, when userspace changes an existing address
> to add NOPREFIXROUTE (to an address that didn't have this flag). This is
> done because when the address was added, a prefix route was created for it.
> Since the user now wants to handle this route by himself, we cleanup this
> route.
> 
> This cleanup of the route is not totally robust. There is no guarantee,
> that the route we are about to delete was really the one added by the
> kernel. This behavior does not change by the patch, and in practice it
> should work just fine.
> 
> Signed-off-by: Thomas Haller <thaller@redhat.com>

I think, this is now simpler than the original version.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
