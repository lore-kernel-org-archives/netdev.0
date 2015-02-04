From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3 2/3] genetlink: disallow subscribing to unknown mcast
 groups
Date: Wed, 04 Feb 2015 17:16:04 +0100
Message-ID: <1423066564.4741.7.camel@sipsolutions.net>
References: <1421404634-8973-1-git-send-email-johannes@sipsolutions.net>
	 <1421404634-8973-2-git-send-email-johannes@sipsolutions.net>
	 <87egq5uc07.fsf@nemi.mork.no> <87d25pit90.fsf@nemi.mork.no>
	 <1423064608.4741.6.camel@sipsolutions.net> <874mr1isch.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jeff Layton <jeff.layton@primarydata.com>,
	Sedat Dilek <sedat.dilek@gmail.com>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55209 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755497AbbBDQQJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2015 11:16:09 -0500
In-Reply-To: <874mr1isch.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-04 at 16:55 +0100, Bj=C3=B8rn Mork wrote:

> This was never noticed before because there are only two users,
> netfilter and generic netlink,  and both were willing to accept the
> off-by-one values without much fuzz.

Generic netlink didn't even have it until my patchset.

I think audit also uses the callback, but only for permissions checks
and doesn't care about the group at all.

johannes
