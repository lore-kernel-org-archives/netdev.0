From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 0/8] alx fixes/improvements
Date: Sat, 29 Jun 2013 19:23:12 +0200
Message-ID: <1372526600-15934-1-git-send-email-johannes@sipsolutions.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:58298 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751629Ab3F2RXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 13:23:25 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <johannes@sipsolutions.net>)
	id 1Usyrs-0006aE-0n
	for netdev@vger.kernel.org; Sat, 29 Jun 2013 19:23:24 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unfortunately WoL is broken and the system always wakes up
immediately, and the code also looks rather odd to me. As I
can't seem to fix it (with admittedly mostly random hacking)
I'm removing it, sorry. Having the system come back from
sleep immediately doesn't seem very useful though, I'm sure
it can be added back by somebody more interested than me.

johannes
