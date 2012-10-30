From: Stephen Hemminger <shemminger@vyatta.com>
Subject: tcp_metrics: dumb bug
Date: Tue, 30 Oct 2012 08:59:20 -0700
Message-ID: <20121030085920.3c64ebd1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41720 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932350Ab2J3QAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2012 12:00:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

https://bugzilla.kernel.org/show_bug.cgi?id=49171

Description From David Binderman 2012-10-21 10:31:05 (-) [reply]
The source code is

        if (nla_len(a) != sizeof(sizeof(struct in6_addr)))

I'm surprised that compiles. Suggest remove one of the sizeofs.
