From: David Miller <davem@davemloft.net>
Subject: net-2.6.24 rebased
Date: Thu, 06 Sep 2007 03:57:56 -0700 (PDT)
Message-ID: <20070906.035756.41664070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:58531
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755173AbXIFK55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 06:57:57 -0400
Received: from localhost (picasso.davemloft.net [127.0.0.1])
	by picasso.davemloft.net (8.13.8/8.13.8) with ESMTP id l86Avu8D000850
	for <netdev@vger.kernel.org>; Thu, 6 Sep 2007 03:57:56 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Upstream got a backport of my netdev->priv fixes for the
cxgb3 driver, creating a bunch of conflicts with the napi_struct
changes, so I took the opportunity to refresh the tree and
combine some bug fixes into the changes that introduced those
bugs :-) (bug fix attributions were added to the changelogs
as needed)

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.24.git

I've tried to sanity check this rebase as best as possible
but mistakes are always possible especially since I'm doing
this from the kernel summit in Cambridge :-)

I've kept the previous tree around as "bak-net-2.6.24.git"
so it can be referenced for researching potential mistakes.

Enjoy!
