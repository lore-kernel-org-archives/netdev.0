From: Jens Rosenboom <jens@mcbone.net>
Subject: [RFC] ipv6: Change %pI6 format to output compacted addresses?
Date: Wed, 12 Aug 2009 17:39:20 +0200
Message-ID: <1250091560.6641.48.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Linux Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from leia.mcbone.net ([194.97.104.42]:47538 "EHLO leia.mcbone.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751607AbZHLPj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 11:39:27 -0400
Received: from fnki-ws00028.freenet-ag.de ([194.97.6.48])
	by leia.mcbone.net with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <jens@mcbone.net>)
	id 1MbFvD-0008JB-Mt
	for netdev@vger.kernel.org; Wed, 12 Aug 2009 15:39:27 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the output looks like 2001:0db8:0000:0000:0000:0000:0000:0001
which might be compacted to 2001:db8::1. The code to do this could be
adapted from inet_ntop in glibc, which would add about 80 lines to
lib/vsprintf.c. How do you guys value the tradeoff between more readable
logging and increased kernel size?

This was already mentioned in
http://kerneltrap.org/mailarchive/linux-netdev/2008/11/25/4231684 but
noone seems to have taken up on it.

