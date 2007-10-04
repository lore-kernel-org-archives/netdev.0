From: "John W. Linville" <linville@tuxdriver.com>
Subject: wireless-dev dead, long live wireless-2.6
Date: Thu, 4 Oct 2007 14:47:15 -0400
Message-ID: <20071004184715.GI6037@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2513 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756756AbXJDTIU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2007 15:08:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greetings,

This message is perhaps a few days late -- better late than never. :-)

The big news is that wireless-dev is now dead, defunct, kaput.
Please discontinue any use of wireless-dev or any of its clones.
If you need access to the contents of that tree for historical
purposes, please see the snapshot in my wireless-legacy tree:

	git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-legacy.git wireless-dev-2007-09-24

I will remove the wireless-dev repository from kernel.org shortly
after sending this message.  From now on, please use the 'everything'
branch of wireless-2.6 as the base for new wireless development.

	git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git everything

Please note that this branch is subject to rebasing.  In general
it will be rebased whenever Linus christens a new -rcX release,
sometimes more often than that.  "git rebase" and "git cherry-pick"
are your friends.

As always, patches based on a vanilla tree from Linus (or the
'master' branch of wireless-2.6) are acceptable or even preferable
for those patches which do not depend on other pathes already in the
wireless-2.6 tree.  Otherwise, base your patches on the 'everything'
branch as described above.

Most of the other branches in wireless-2.6 are only there for
administrative purposes.  You can and should ignore them, with possibly
a couple of exceptions.

One of two possible branches of interest to some is the
'mac80211-attic' branch.  This branch mostly contains patches
supporting hostap functionality for mac80211.  These patches will
not be merged as-is due to unsettled user interface issues.  I have
preserved them on this branch solely as a courtesy to those who need
this functionality.  I expect for this functionality to be replaced
RSN by work underway from Johannes Berg.

The other possible branch of interest is the 'mac80211-dungeon'
branch.  This branch contains several patches for 802.11n and other
advanced functionality (e.g.  DLS).  However, the mac80211 component
maintainers have strongly objected to these patches for a variety
of reasons.  The various parties are still working to resolve the
issues preventing these patches from being merged.  In the meantime
I have preserved these patches on this branch as a courtesy to those
who need them as well.

I hope this message clears-up some questions that people have been
expressing.  If there are other questions, please feel free to ask.

Thanks!

John
-- 
John W. Linville
linville@tuxdriver.com
