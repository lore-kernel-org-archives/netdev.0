From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 0/5] netlink/genetlink cleanups & multicast improvements
Date: Mon, 22 Dec 2014 18:56:34 +0100
Message-ID: <1419270999-22165-1-git-send-email-johannes@sipsolutions.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35029 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755224AbaLVR4p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 12:56:45 -0500
Received: by sipsolutions.net with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_CBC_SHA256:128)
	(Exim 4.84)
	(envelope-from <johannes@sipsolutions.net>)
	id 1Y37Dn-00056k-Vm
	for netdev@vger.kernel.org; Mon, 22 Dec 2014 18:56:44 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm looking at using the multicast group functionality in a way that would
benefit from knowing when there are subscribers to avoid collecting the
required data when there aren't any. During this I noticed that the unbind
for multicast groups doesn't actually work - it's never called when sockets
are closed. Luckily, nobody actually uses the functionality.

While looking at the code trying to find why it's not called and where the
multicast listeners are actually removed, I found the potential cleanup in
patch 3. Patch 2 also has a cleanup for a generic netlink API in this area.

johannes
