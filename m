From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Fwd: [Bug 447812] New: Netlink messages from "tc"  to sch_netem
 module are not interpreted correctly
Date: Wed, 21 May 2008 15:16:23 -0700
Message-ID: <48349F37.60709@hp.com>
References: <20080521214523.GB22591@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:35265 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754912AbYEUWQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 18:16:26 -0400
In-Reply-To: <20080521214523.GB22591@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones wrote:
> # If the kernel is acting up this will cause a kernel
> # message of the following form to be emitted and visible
> # via dmesg | tail
> #  netlink: 12 bytes leftover after parsing attributes.

Not _much_ added value, but I can add that I see a similar message - 
with 8 replacing 12 - when running netperf "omni" tests:

netlink: 8 bytes leftover after parsing attributes.
netlink: 8 bytes leftover after parsing attributes.
netlink: 8 bytes leftover after parsing attributes.
c12:~/netperf2_trunk# uname -a
Linux c12 2.6.24-1-mckinley #1 SMP Sat Apr 19 00:19:28 UTC 2008 ia64 
GNU/Linux

And netperf was compiled on that system itself so ostensibly had the 
correct headers etc...

I also see those messages on a 2.6.26-rc1 kernel:

izzy:~/netperf2_trunk# ./configure --enable-omni
...
izzy:~/netperf2_trunk# src/netperf -t omni -H c12.cup.hp.com -- -o foo
OMNI TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to c12.cup.hp.com 
(16.89.133.212) port 0 AF_INET
netlink: 8 bytes leftover after parsing attributes.
Throughput
94.02
izzy:~/netperf2_trunk# uname -a
Linux izzy 2.6.26-rc1-raj #1 SMP Thu May 8 15:24:23 PDT 2008 ia64 GNU/Linux
izzy:~/netperf2_trunk# cat foo
throughput

rick jones
