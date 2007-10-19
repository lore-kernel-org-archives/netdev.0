From: Andreas Henriksson <andreas@fatal.se>
Subject: iproute2: git pull request from debian repo.
Date: Fri, 19 Oct 2007 14:27:53 +0200
Message-ID: <20071019122753.GA30078@scream.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, andreas@fatal.se
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:46440 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753388AbXJSMbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 08:31:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

We now have our brand new git repo set up for the debian package. We have
created a branch called "patches" where we are going to put stuff that we
hope will get merged upstream.

I'm sending out this pull request to get confirmation about if we are on the
right track ...

The repo url is git://git.debian.org/git/collab-maint/pkg-iproute.git
and the branch you're supposed to look at is "patches", as I mentioned.

(gitweb available at:
http://git.debian.org/?p=collab-maint/pkg-iproute.git;a=summary )

It currently only contains two fixes:
- trivial syntax fix in the ss(8) manpage, by Justin Pryzby.
  (Should be a no-brainer.)
- ip addr flush loop fix (from ubuntu), by Daniel Silverstone
  (Equivalent to the treatment "ip neigh flush" previously got.
   This obsoletes the patch from Alexander Wirt which was dropped
   from the last patch submission.)

The patches branch is currently based on the v2.6.23-071016 release, and we
intend to rebase it when you do a new release.

Please notify me about anything I've set up wrong (and helpful hints on how
to do it right, would be deeply appreciated since I'm a complete git newbie).
I would also like to ask if this pull request should be followed up by
posting the patches to the mailing list or if a public git repo is considered
enough? If you want me to also post the individual patches, I'd be very happy
if you have some helpful hints on how to most easily export just the ones in
the tree which doesn't come from the upstream branch and send them out...

Have a nice weekend!

-- 
Regards,
Andreas Henriksson
