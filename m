From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 0/8] generic netlink multicast group cleanup
Date: Sat, 16 Nov 2013 18:03:41 +0100
Message-ID: <1384621429-24543-1-git-send-email-johannes@sipsolutions.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:57910 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375Ab3KPREA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 12:04:00 -0500
Received: by sipsolutions.net with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <johannes@sipsolutions.net>)
	id 1VhjHo-0000Bt-EC
	for netdev@vger.kernel.org; Sat, 16 Nov 2013 18:03:56 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So I looked at the generic netlink multicast groups, and it turns out
that two users (drop_monitor and quota) abuse the groups.

Making the groups static has multiple benefits from space usage and    
initialization code complexity point of view, but also makes it much
harder to abuse the groups like that again in the future since each
call using them can check the group is actually valid in the family.

johannes
