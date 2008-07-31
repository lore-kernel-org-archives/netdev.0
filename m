From: Rick Jones <rick.jones2@hp.com>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 10:00:32 -0700
Message-ID: <4891EFB0.4040003@hp.com>
References: <20080730235004.GC21999@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:17336 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756964AbYGaRAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 13:00:36 -0400
In-Reply-To: <20080730235004.GC21999@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
> When using sendfile() to send a GiB worth of zeroes over a single TCP
> connection to another host on a 100 Mb/s network, with a vanilla
> 2.6.27-rc1 kernel, this runs as expected at wire speed, taking the
> following amount of CPU time per test:
> 
> 	sys     0m5.410s
> 	sys     0m5.380s
> 	sys     0m5.620s
> 	sys     0m5.360s

That's output from "time" run against your test program right?  Are 
folks confident that will account for all the CPU time consumed on 
behalf of that program?  FWIW netperf is unwilling to make such an 
assumption.  Perhaps I and it are being too paranoid but there you have 
it :)

rick jones
fwiw, there is a TCP_SENDFILE test in netperf
