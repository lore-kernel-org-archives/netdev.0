From: Roland Dreier <rdreier@cisco.com>
Subject: Bogus commit 70eba18b ("make bnx2x select ZLIB_INFLATE")?
Date: Sat, 08 Dec 2007 19:07:22 -0800
Message-ID: <adasl2ca7md.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eliezer Tamir <eliezert@broadcom.com>,
	Lee Schermerhorn <lee.schermerhorn@hp.com>
To: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:15496 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbXLIDH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 22:07:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 70eba18b ("make bnx2x select ZLIB_INFLATE") in Linus's tree
seems bogus.  As far as I can tell, bnx2x is not upstream yet, and the
commit in question actually adds "select ZLIB_INFLATE" to the TEHUTI
config, since there is no BNX2X config option (and also I don't see
any reference to zlib in any tehuti files).

I assume this is some sort of merge problem that got added to the
wrong tree and should be reverted upstream.

 - R.
