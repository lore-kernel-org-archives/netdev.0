From: Andreas Henriksson <andreas@fatal.se>
Subject: ipv6 preferred lifetime wraparound...
Date: Thu, 02 Jul 2009 21:23:43 +0200
Message-ID: <1246562623.8814.21.camel@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jens Rosenboom <me@jayr.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtah11.telenor.se ([62.127.194.4]:34081 "EHLO mtah11.telenor.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145AbZGBTpJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2009 15:45:09 -0400
Received: from iph1.telenor.se (iph1.telenor.se [195.54.127.132])
	by mtah11.telenor.se (Postfix) with ESMTP id 6E33C32F57
	for <netdev@vger.kernel.org>; Thu,  2 Jul 2009 21:22:37 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

I spotted your patch[1] to prevent ipv6 preferred lifetime wraparound.
It looks to me like you fixed the preferred lifetime, but did not touch
the valid lifetime. According to a debian bugreport[2] it seems both of
them like to wrap around. Shouldn't the "valid -= tval;", visible in
your patch context, also be conditional similar to your change for
"preferred -= tval;" ?


Regards,
Andreas Henriksson

[1]: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=a1faa69810b2af562b70b2a71c116c7d03575dd3
[2]: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=518710

