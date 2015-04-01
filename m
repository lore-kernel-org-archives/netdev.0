From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: ethtool: git tree not updated to v3.18
Date: Wed, 1 Apr 2015 14:30:06 -0700
Message-ID: <20150401143006.000001f7@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com
To: netdev@vger.kernel.org, bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:41747 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751566AbbDAVaH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 17:30:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben, 

When trying to check a bug just now I noticed that the master
branch of
git://git.kernel.org/pub/scm/network/ethtool/ethtool

still points to the v3.16 tag.

But kernel.org shows version 3.18 released.  I did some quick
investigation and it looks like the v3.18 tag points to a dangling
commit that is not on a branch.

$ git log --graph --oneline v3.18 |head -n5
* ba9a11a Release version 3.18.
* 1e8811a Fix build with musl by using more common typedefs
* 99bc878 bug fix: SFP Tx BIAS uses memory wrong offset
* 4614098 Release version 3.16.
* 14ef76c test-cmdline: Disable test cases for --rxfh hash key parsing

$ git log --graph --oneline origin/master |head -n5
* 4614098 Release version 3.16.
* 14ef76c test-cmdline: Disable test cases for --rxfh hash key parsing
* 86c0326 ethtool: Support for configurable RSS hash key
* e633626 ethtool-copy.h: sync with net
* 05b8ad5 Release version 3.14.

Maybe you can merge the commits from your working branch back onto
master and make another 3.18.1 tag or something.

I just did:
git checkout master
git merge v3.18

which worked okay, I think.
