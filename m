From: Greg Lindahl <greg@blekko.com>
Subject: Treason uncloaked / Broken peer again
Date: Sat, 21 Feb 2009 11:58:29 -0800
Message-ID: <20090221195829.GA14779@bx9.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rc.bx9.net ([64.13.160.15]:30130 "EHLO rc.bx9.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751968AbZBUUZi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Feb 2009 15:25:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A recent set of fiddling to our web crawler has resulted in crawled
Linux hosts frequently getting "Treason uncloaked" messages in their
dmesg. This has resulted in a modest amount of hate mail, surprisingly
little given that we crawl millions of hosts per day.

We're running the RHEL 5.2's kernel, and I have a remote webserver of
my own running RHEL 5.2 that's getting the messages. If you look in
your own webserver dmesg and see treason emanating from
38.108.180.XXX/24, that's me.

Unfortunately, I haven't made the thing deterministic. My suspicion is
that there's another bug similar to:

http://github.com/github/linux-2.6/commit/2ad41065d9fe518759b695fc2640cf9c07261dd2

Any advice on how to narrow down the bug? I was hoping I could get a
tcpdump of a treasonous conversation and hand it over to you guys.

-- greg


