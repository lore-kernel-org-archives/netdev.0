From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC 3/8] quota/genetlink: use proper genetlink multicast APIs
Date: Mon, 18 Nov 2013 15:12:20 +0100
Message-ID: <20131118141220.GD3921@quack.suse.cz>
References: <1384621429-24543-1-git-send-email-johannes@sipsolutions.net>
 <1384621429-24543-4-git-send-email-johannes@sipsolutions.net>
 <20131118123403.GC3921@quack.suse.cz>
 <1384778694.17916.5.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Kara <jack@suse.cz>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58521 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751185Ab3KROMV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Nov 2013 09:12:21 -0500
Content-Disposition: inline
In-Reply-To: <1384778694.17916.5.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon 18-11-13 13:44:54, Johannes Berg wrote:
> On Mon, 2013-11-18 at 13:34 +0100, Jan Kara wrote:
> > Anyway, I'll fix quota_nld (userspace daemon consuming quota netlink
> > messages) to use multicast groups properly with a fallback to previous
> > behavior in case that fails (to keep compatibility with older kernels) and
> > since I don't believe anyone else is using this interface (and even
> > quota_nld isn't widely used), 
> 
> Heh. If you want a different group name, that's fine, I just gave it any
> name ... We could call it "events" for example, since the group name is
> always qualified by the family name anyway.
  OK, "events" might be a better name then.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
