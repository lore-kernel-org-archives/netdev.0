From: David Miller <davem@davemloft.net>
Subject: net-next-2.6 reverts.... PLEASE READ
Date: Mon, 07 Jul 2008 22:43:36 -0700 (PDT)
Message-ID: <20080707.224336.59099363.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60284
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751312AbYGHFng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 01:43:36 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id D0FE9C8D0B5
	for <netdev@vger.kernel.org>; Mon,  7 Jul 2008 22:43:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I had to pop off the top 3 commits in net-next-2.6 in order to fix
them up and get rid of some very unintentional changes that slipped
in.

Some defconfig files got modified in the NAPI config option removal
commits that went in yesterday, and that's not supposed to happen.

If you've already pulled, you can fix your net-next-2.6 tree like
this:

1) Put "38b221957b155ef410bdc28856a66386303fbd5a" into the
   .git/refs/heads/master file.

2) Repull.

I hope this doesn't inconvenience too many people.

I didn't want to even think about rebuilding the entire tree
just to fix this. :-/
