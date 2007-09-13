From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [v3 PATCH 0/2] Add RCU locking to SCTPaddress management
Date: Thu, 13 Sep 2007 15:34:35 -0400
Message-ID: <11897120771278-git-send-email-vladislav.yasevich@hp.com>
Cc: lksctp@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:60535 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753851AbXIMTei (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 15:34:38 -0400
Received: from smtp2.fc.hp.com (smtp2.fc.hp.com [15.11.136.114])
	by atlrel9.hp.com (Postfix) with ESMTP id 2062935F4B
	for <netdev@vger.kernel.org>; Thu, 13 Sep 2007 15:34:38 -0400 (EDT)
Received: from galen.zko.hp.com (galen.zko.hp.com [16.116.97.23])
	by smtp2.fc.hp.com (Postfix) with ESMTP id CD0FD22674A
	for <netdev@vger.kernel.org>; Thu, 13 Sep 2007 19:34:37 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All

Thanks to Sridhar Samudral and Paul McKenney for all the help and comments.
I think this is a final version, unless someone else can spot more problems.
I've ran this under heavy load and it the patches behaves well.

I think patch 1 is a candidate for 2.6.23 since it fixes a bug, but splitting
these seems a bit odd to me.  I'll leave it to DaveM to decide where to
put them.

Thanks
-vlad
