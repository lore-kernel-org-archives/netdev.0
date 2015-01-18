From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] netlink: make nlmsg_end() and genlmsg_end() void
Date: Sun, 18 Jan 2015 14:27:53 +0100
Message-ID: <1421587673.1965.0.camel@sipsolutions.net>
References: <1421442540-10244-1-git-send-email-johannes@sipsolutions.net>
	 <20150118.010446.405197490184285420.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55522 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589AbbARN16 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jan 2015 08:27:58 -0500
In-Reply-To: <20150118.010446.405197490184285420.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-01-18 at 01:04 -0500, David Miller wrote:

> I like this, applied, thanks Johannes.
> 
> You know, I would even be willing to apply a patch adjusting that phonet
> case.  So feel free to submit that.

I can do that - I agree that it's probably fine (you'd have to be not
using libnl and writing bad code to get it wrong) but didn't really want
to do it in that patch.

Anyway it looks like I broke some dump (as reported by Marcel) so I'll
have to dig into that first.

johannes
