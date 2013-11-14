From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 0/7] genetlink: reduce ops size and complexity
Date: Thu, 14 Nov 2013 10:14:39 +0100
Message-ID: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:47799 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478Ab3KNJOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 04:14:52 -0500
Received: by sipsolutions.net with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <johannes@sipsolutions.net>)
	id 1Vgt0j-0000ej-1B
	for netdev@vger.kernel.org; Thu, 14 Nov 2013 10:14:49 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches updates a few genetlink users and then
makes the ops a static const array, reducing kernel size and
code complexity.

Comments welcome.

johannes
