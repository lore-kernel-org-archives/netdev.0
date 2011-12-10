From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Optimizing tc filters
Date: Sat, 10 Dec 2011 13:16:28 -0500
Message-ID: <1323540988.3159.133.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:54756 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750785Ab1LJSQc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Dec 2011 13:16:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  Given that there are several ways to direct packets into
the appropriate queue, I was wondering which ways are generally more
efficient.  There seem to be a number of email discussions but nothing
authoritative.  From those discussions, it would seem that for most
corporate usage (as in more traffic than a home user) we would have from
most efficient to least efficient:

1) Mark the connection with CONNMARK and us --restore-mark to mark all
packets in the connection for classification via an fw filter

2) Use the iptables CLASSIFY target

3) u32 filter

4) Mark individual packets and use an fw filter - one email thread says
this is more efficient than #3

Is this correct?
