From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: d80211-drivers updated (zd1211rw-d80211 synced with zd1211rw)
Date: Mon, 4 Dec 2006 07:51:45 -0500
Message-ID: <20061204125139.GA10912@tuxdriver.com>
References: <200612040250.43955.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd@gentoo.org>, Ulrich Kunitz <kune@deine-taler.de>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:34569 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S936786AbWLDMwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 07:52:07 -0500
To: Michael Wu <flamingice@sourmilk.net>
Content-Disposition: inline
In-Reply-To: <200612040250.43955.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 04, 2006 at 02:50:39AM -0500, Michael Wu wrote:

> Other (d80211) wireless drivers are welcome 
> to send patches this way if they do not have their own git tree for Linville 
> to pull.

Please don't do this.  It adds to my pain for reviewing patches.

I don't mind (and maybe even like) pulling w/ git from primary driver
authors.  But, I would prefer not to add extra layers of git between
me and the patch authors.

Similarly, I would prefer for Ulrich or Daniel to maintain the zd1211rw
git tree unless you (i.e. Michael) are going to be one of the primary
authors going forward.

While I'm complaining :-), I would probably prefer it if you had
adm8211 and p54 in separate git trees (or at least on separate
branches) as well.  That way, if there is a problem in a p54 patch
series, I can still pull adm8211 (or vice versa).

It is not my intent to scold (so please don't feel scolded).  It just
is counter-productive to prematurely consolidate merging duties.

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
