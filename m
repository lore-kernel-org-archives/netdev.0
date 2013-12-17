From: David Gibson <david@gibson.dropbear.id.au>
Subject: [0/2] netxen: bug fix and diagnostics for possible (hardware?) bug
Date: Tue, 17 Dec 2013 16:22:31 +1100
Message-ID: <1387257753-18676-1-git-send-email-david@gibson.dropbear.id.au>
Cc: netdev@vger.kernel.org, snagarka@redhat.com, tcamuso@redhat.com,
	vdasgupt@redhat.com
To: manish.chopra@qlogic.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:40470 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751016Ab3LQFUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 00:20:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At Red Hat, we've hit a couple of customer cases with crashes in the
netxen driver due to list corruption.  This seems to be very rarely
triggered, and unfortunately the dumps we have don't have enough
information to be certain of the cause, although we have a possible
theory.

I'm suggesting, therefore a patch to add some sanity checking which
should help to at least localize and mitigate the problem when someone
hits it in future.  Please let me know if there's a better approach to
doing this.

That's 2/2.  1/2 is a fix for a clear bug I spotted along the way, but
not one that could cause the symptoms we've seen.
