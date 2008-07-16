From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: iproute2: no error message when link up command fails.
Date: Thu, 17 Jul 2008 00:27:17 +0200
Message-ID: <1216247237.31646.12.camel@amd64.fatal.se>
References: <20080716220058.GA31425@amd64.fatal.se>
	 <20080716150320.63f20215@extreme>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com,
	Johannes Berg <johannes@sipsolutions.net>,
	489340@bugs.debian.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:42277 "EHLO
	amd64.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751972AbYGPWXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 18:23:43 -0400
In-Reply-To: <20080716150320.63f20215@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ons, 2008-07-16 at 15:03 -0700, Stephen Hemminger wrote:
> On Thu, 17 Jul 2008 00:00:58 +0200
> Andreas Henriksson <andreas@fatal.se> wrote:
[...]
> > +						fprintf(stderr, "Unknown netlink error.\n");
> >  						return 0;
[..]
> libnetlink shouldn't print the error, it needs to be done by the caller.
... and iproute should exit with a proper error code. This isn't
possible today, as there's no way for the caller to detect the error!
I was just trying to be a bit helpful on where we end up in the code.

If anyone could help out with how to modify the code to solve all this,
that would be nice. I don't understand the current code tries to do.

(By the way, most uses of rtnl_* seems to be if (rtnl_* < 0) exit(1); in
iproute2 currently. The error messages are in libnetlink.)


-- 
Regards,
Andreas Henriksson
