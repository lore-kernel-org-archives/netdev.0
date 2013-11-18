From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 3/8] quota/genetlink: use proper genetlink multicast APIs
Date: Mon, 18 Nov 2013 13:44:54 +0100
Message-ID: <1384778694.17916.5.camel@jlt4.sipsolutions.net>
References: <1384621429-24543-1-git-send-email-johannes@sipsolutions.net>
	 <1384621429-24543-4-git-send-email-johannes@sipsolutions.net>
	 <20131118123403.GC3921@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jan Kara <jack@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:36943 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461Ab3KRMo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 07:44:58 -0500
In-Reply-To: <20131118123403.GC3921@quack.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-18 at 13:34 +0100, Jan Kara wrote:

> Ah, sorry for messing that up. When I was writing this, libnl didn't have
> support for multicast groups and so I didn't figure out from its documentation
> there are any multicast groups at all... I'd also mention that
> documentation of generic netlink at
> http://www.linuxfoundation.org/collaborate/workgroups/networking/generic_netlink_howto
> (pointed to from Documenation/networking/generic_netlink.txt) doesn't
> mention anything about multicast groups either. So chances for messing
> things up are pretty high...

Bugger. I guess we should take a look at adding something about
multicast groups etc.

> Anyway, I'll fix quota_nld (userspace daemon consuming quota netlink
> messages) to use multicast groups properly with a fallback to previous
> behavior in case that fails (to keep compatibility with older kernels) and
> since I don't believe anyone else is using this interface (and even
> quota_nld isn't widely used), 

Heh. If you want a different group name, that's fine, I just gave it any
name ... We could call it "events" for example, since the group name is
always qualified by the family name anyway.

I'll remove the comment about it not being really used as well then.

> I think we can remove this hack from generic
> netlink layer in a couple of years (hurray to a paragraph long
sentence
> ;).

:)

> Thanks for fixing this and you can add:
> Acked-by: Jan Kara <jack@suse.cz>

Will do, thanks.

johannes
