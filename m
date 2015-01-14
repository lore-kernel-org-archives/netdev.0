From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [ 2375.793397] WARNING: CPU: 0 PID: 1149 at
 net/netlink/genetlink.c:1037 genl_unbind+0xc0/0xd0()
Date: Wed, 14 Jan 2015 23:48:20 +0100
Message-ID: <1421275700.1950.34.camel@sipsolutions.net>
References: <20150114161334.28acf5fc@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Layton <jeff.layton@primarydata.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:33139 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750965AbbANWsX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2015 17:48:23 -0500
In-Reply-To: <20150114161334.28acf5fc@tlielax.poochiereds.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-01-14 at 16:13 -0500, Jeff Layton wrote:
> While running the trinity fuzzer in a KVM guest, I ^C'ed it at an
> (apparent) inopportune moment, and saw a bunch of these WARN_ONs pop:

A bunch?!

> [ 2375.793396] ------------[ cut here ]------------
> [ 2375.793397] WARNING: CPU: 0 PID: 1149 at net/netlink/genetlink.c:1037 genl_unbind+0xc0/0xd0()

This warning is supposed to happen only when you somehow manage to
unsubscribe from a generic netlink group that doesn't actually exist, or
so.

Do you have any sort of log/trace of what trinity actually did at/before
this point?

johannes
