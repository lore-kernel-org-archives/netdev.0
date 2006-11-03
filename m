From: "John W. Linville" <linville@tuxdriver.com>
Subject: New stuff in wireless-dev, wireless developers please pull...
Date: Thu, 2 Nov 2006 23:30:30 -0500
Message-ID: <20061103043024.GF2989@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:18705 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751453AbWKCEyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 23:54:10 -0500
Received: from ra.tuxdriver.com (ra.tuxdriver.com [127.0.0.1])
	by ra.tuxdriver.com (8.13.7/8.13.7) with ESMTP id kA34rxR4031728
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 2 Nov 2006 23:54:04 -0500
Received: (from uucp@localhost)
	by ra.tuxdriver.com (8.13.7/8.13.6/Submit) with UUCP id kA34Vnsb031516
	for netdev@vger.kernel.org; Thu, 2 Nov 2006 23:31:49 -0500
Received: from laptop (localhost.localdomain [127.0.0.1])
	by laptop (8.13.7/8.13.7) with ESMTP id kA34UU5U015814
	for <netdev@vger.kernel.org>; Thu, 2 Nov 2006 23:30:30 -0500
Received: (from linville@localhost)
	by laptop (8.13.7/8.13.7/Submit) id kA34UUoo015812
	for netdev@vger.kernel.org; Thu, 2 Nov 2006 23:30:30 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm basically caught-up on merging for wireless-dev.  Here is the URL,
just in case you forgot... :-)

	git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git

This includes a pull from Michael Buesch for bcm43xx stuff, a fresh
pull from Jiri for stack stuff, the addition of the p54 driver from
Michael Wu, Larry's wireless stats patches, and some misc patches
from (or through) David Kimdon and others.  I apologize if I've left
anyone out.  You'll still be in the changelogs... :-)

I've also added a 'pending' branch, with similar policies to the
'pending' branch in wireless-2.6 (i.e it means I've got the patch,
but I'm waiting on some feedback or changes, etc).

One big addition is the cfg80211/nl80211 stuff from Johannes.  I'm not
quite confident that the Kconfig stuff is right, but the code is there.
This is our WE successor, so driver authors please take notice and
plan for your driver's migration to the new configuration regime.

Please pull the tree and check things out.  If you sent a patch more
than a few days ago and it isn't in there, I've probably missed it
or discarded it for some reason.  Please feel free to resubmit any
missing patches.

Thanks for your support, and for all the great patches!  Keep 'em
coming! :-)

John
-- 
John W. Linville
linville@tuxdriver.com
