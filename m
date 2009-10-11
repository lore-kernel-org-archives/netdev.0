From: Frans Pop <elendil@planet.nl>
Subject: Re: Enable syn cookies by default
Date: Sun, 11 Oct 2009 12:26:43 +0200
Message-ID: <200910111226.44828.elendil@planet.nl>
References: <b2cc26e40910100601q7aed04acjcc9973ef06e6458f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Olaf van der Spek <olafvdspek@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Cpsmtpm-eml107.kpnxchange.com ([195.121.3.11]:56497 "EHLO
	CPSMTPM-EML107.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756656AbZJKK1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2009 06:27:22 -0400
In-reply-To: <b2cc26e40910100601q7aed04acjcc9973ef06e6458f@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This question is better asked on the kernel network development list.
Original mail from Olaf below.

Cheers,
FJP

=================
Hi,

I'm forwarding Debian feature request #520668.

Could syn cookies be enabled by default?

AFAIK syn cookies only get send when the half-open TCP connection
queue is full. So stuff like window scaling should work fine in normal
situations.

Speaking of which:
When the half-open TCP connection queue is full and syn cookies are
enabled, you get a message like "kernel: possible SYN flooding on port
2710. Sending cookies."
However when syn cookies are disabled, you don't get any message (in
kern.log), although connections to your server are timing out.
Could such a message be added?
Maybe with a suggestion to increase the size of that queue or to
enable syn cookies.

Greetings,

Olaf

http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=520668
http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=520667
https://bugs.launchpad.net/ubuntu/+bug/57091
