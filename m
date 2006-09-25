From: "John W. Linville" <linville@tuxdriver.com>
Subject: wireless-2.6 now has a 'pending' branch (was Re: Please pull 'upstream' branch of wireless-2.6.git)
Date: Mon, 25 Sep 2006 17:55:36 -0400
Message-ID: <20060925215535.GH16949@tuxdriver.com>
References: <20060925215037.GG16949@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:35338 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751493AbWIYV7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 17:59:43 -0400
Received: from bilbo.hq.tuxdriver.com ([70.61.120.53])
	by ra.tuxdriver.com (8.13.7/8.13.7) with ESMTP id k8PLsi3W029793
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 25 Sep 2006 17:54:49 -0400
Received: from bilbo.hq.tuxdriver.com (localhost.localdomain [127.0.0.1])
	by bilbo.hq.tuxdriver.com (8.13.1/8.13.1) with ESMTP id k8PLtaeI010657
	for <netdev@vger.kernel.org>; Mon, 25 Sep 2006 17:55:36 -0400
Received: (from linville@localhost)
	by bilbo.hq.tuxdriver.com (8.13.1/8.13.1/Submit) id k8PLtasH010656
	for netdev@vger.kernel.org; Mon, 25 Sep 2006 17:55:36 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060925215037.GG16949@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 25, 2006 at 05:50:43PM -0400, John W. Linville wrote:
> The following changes since commit 7c250413e5b7c3dfae89354725b70c76d7621395:
>   Al Viro:
>         pata_pdc2027x iomem annotations
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

It's been a little while, and for that I apologize.  Work, kids, elderly
relatives, blah, blah, blah... :-(

Anyway, this covers _almost_ everything I've got in my queue for pushing
upstream.  The exceptions are a couple of patches posted very recently
which I'd like to give a chance to simmer first.  That gives people a
little more time to review them rather than asking me to revert them
later... :-)

Anyway, I know have a "pending" branch.  Patches on this branch are
really only there for three reasons:

	-- to let the author know I got the patch;

	-- to let me know that the patch applies to the tree; and,

	-- to enhance a patch's exposure for review.

I do not intend to add my "Signed-off-by:" to patches on the pending
branch.  This is intended to further signify (albeit subtley) that
they are not yet queued for upstream.  This also implies that I won't
be pulling from that branch, so you shouldn't be pulling from there
into your own trees either (except for the purpose of reviewing the
patches, of course).  I probably won't usually announce new patches
in the pending branch, so feel free to check it periodically.

For now, the pending branch is just a trial intended to add more
visibility to the process.  Feel free to propose changes to the
pending process if it does not seem to be effective.  YMMV, objects
in mirror may be closer than they appear, you are not expected to
understand this, etc... :-)

John

P.S.  Individual patches are available here (w/o using git):

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/pending

---

The following changes since commit a67ab2bde752b26be75d4b68ecead9a14692eac5:
  Larry Finger:
        bcm43xx: fix netdev watchdog timeouts

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git pending

Daniel Drake:
      ieee80211: Move IV/ICV stripping into ieee80211_rx

Larry Finger:
      ieee80211: quiet TKIP and CCMP replay messages for identical TSCs

 drivers/net/wireless/bcm43xx/bcm43xx_main.c |    3 +
 drivers/net/wireless/bcm43xx/bcm43xx_xmit.c |   19 ---------
 drivers/net/wireless/ipw2200.c              |   48 +----------------------
 include/net/ieee80211.h                     |    4 ++
 net/ieee80211/ieee80211_crypt_ccmp.c        |    2 -
 net/ieee80211/ieee80211_crypt_tkip.c        |    2 -
 net/ieee80211/ieee80211_rx.c                |   56 ++++++++++++++++++++++++---
 7 files changed, 61 insertions(+), 73 deletions(-)
-- 
John W. Linville
linville@tuxdriver.com
