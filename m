From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 3/8] quota/genetlink: use proper genetlink multicast APIs
Date: Mon, 18 Nov 2013 15:41:46 +0100
Message-ID: <1384785706.17916.18.camel@jlt4.sipsolutions.net>
References: <1384621429-24543-1-git-send-email-johannes@sipsolutions.net>
	 <1384621429-24543-4-git-send-email-johannes@sipsolutions.net>
	 <20131118123403.GC3921@quack.suse.cz>
	 <1384778694.17916.5.camel@jlt4.sipsolutions.net>
	 <20131118141220.GD3921@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jan Kara <jack@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:37258 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167Ab3KROlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 09:41:52 -0500
In-Reply-To: <20131118141220.GD3921@quack.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-18 at 15:12 +0100, Jan Kara wrote:
> On Mon 18-11-13 13:44:54, Johannes Berg wrote:
> > On Mon, 2013-11-18 at 13:34 +0100, Jan Kara wrote:
> > > Anyway, I'll fix quota_nld (userspace daemon consuming quota netlink
> > > messages) to use multicast groups properly with a fallback to previous
> > > behavior in case that fails (to keep compatibility with older kernels) and
> > > since I don't believe anyone else is using this interface (and even
> > > quota_nld isn't widely used), 
> > 
> > Heh. If you want a different group name, that's fine, I just gave it any
> > name ... We could call it "events" for example, since the group name is
> > always qualified by the family name anyway.
>   OK, "events" might be a better name then.

Ok, I'll rename it in my patch.

johannes
