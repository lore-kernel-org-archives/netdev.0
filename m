From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 0/9] genetlink: clean up multicast group APIs
Date: Tue, 19 Nov 2013 15:19:30 +0100
Message-ID: <1384870779-17571-1-git-send-email-johannes@sipsolutions.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:41394 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286Ab3KSOTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 09:19:47 -0500
Received: by sipsolutions.net with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <johannes@sipsolutions.net>)
	id 1Vim9Y-0008QL-9Z
	for netdev@vger.kernel.org; Tue, 19 Nov 2013 15:19:44 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The generic netlink multicast group registration doesn't have to
be dynamic, and can thus be simplified just like I did with the
ops. This removes some complexity in registration code.

Additionally, two users of generic netlink already use multicast
groups in a wrong way, add workarounds for those two to keep the
userspace API working, but at the same time make them not clash
with other users of multicast groups as might happen now.

While making it all a bit easier, also prevent such abuse by adding
checks to the APIs so each family can only use the groups it owns.

johannes
