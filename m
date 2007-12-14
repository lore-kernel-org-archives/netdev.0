From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: What was the reason for 2.6.22 SMP kernels to change how sendmsg is called?
Date: Thu, 13 Dec 2007 16:45:36 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5203FF45B4@orsmsx418.amr.corp.intel.com>
References: <20071213.131753.156591181.davem@davemloft.net> <B1F576FE19C55C43B8D2E31F061B50C04E60B2@exchange.comtrol.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Kevin Wilson" <Kevin.Wilson@comtrol.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59494 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762826AbXLNAuH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 19:50:07 -0500
Content-class: urn:content-classes:message
In-Reply-To: <B1F576FE19C55C43B8D2E31F061B50C04E60B2@exchange.comtrol.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kevin Wilson wrote:
> Nonetheless, a somewhat recent change in your tree, that I could not
> pinpoint on my own, caused the driver to stop functioning properly.
> So after much searching in git/google/sources with no luck, I decided
> to ask for a little assistance, maybe just a hint as to where the
> culprit may be in the tree so I could investigate for myself. For
> SNGs I tried the method that now works but I am still at a loss as to
> (can't find) what changes in the tree caused it to fail.      

Kevin, could you give git-bisect a shot?  if you have two kernel
versions or -rcX tags that work and don't work, then you can use bisect
to help find the patch that causes it.

you can search for from:torvalds and git-bisect to see lots of
instructions from Linus on how to do it.  If you have a fast machine and
a few hours and an automatable test it can go really fast, probably less
than 12 rebuilds.

Good Luck,
  Jesse
