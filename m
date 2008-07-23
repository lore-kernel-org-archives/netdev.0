From: Ben Greear <greearb@candelatech.com>
Subject: Performance degradation on 2.6.25 kernels for http servers
Date: Wed, 23 Jul 2008 13:37:30 -0700
Message-ID: <4887968A.10308@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59146 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754402AbYGWUhc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 16:37:32 -0400
Received: from [192.168.100.194] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id m6NKbU57029016
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 23 Jul 2008 13:37:31 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We noticed something strange today.

We have a test that launches 10 http clients that request a small
URL over and over again.  Keep-alive is enabled on clients and
apache.

When using a 2.6.24 or earlier kernel on the web server, we get around
1200 urls per second completed on each of the 10 clients.  With 2.6.25 kernel
we get around 1000 urls per second completed.  In other words, about
a 20% degradation in connections per second.

We see the same affect when we use standard Fedora kernels as when
we use our own patched kernels.  We see similar degradations when using
FC5 and FC8, and 32-bit and 64-bit installs.  We see similar degradations
on different hardware systems.  We have only tried our modified kernels
and standard Fedora kernels at this time (no un-modified kernels from kernel.org).

It could still be something we are doing wrong, but if anyone
else has a similar test case, I'm curious to know if you see
similar degradations.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

