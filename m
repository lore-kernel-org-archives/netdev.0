From: Ben Greear <greearb@candelatech.com>
Subject: How to grab a block of binary data w/out using ioctls?
Date: Mon, 23 Oct 2006 17:44:24 -0700
Message-ID: <453D61E8.8020400@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:31696 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932390AbWJXAoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2006 20:44:25 -0400
Received: from [192.168.100.224] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id k9O0iOrS007235
	for <netdev@vger.kernel.org>; Mon, 23 Oct 2006 17:44:25 -0700
To: NetDev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since IOCTLs are out of favor these days, what would be
a preferred way to get a block of binary data out of the
kernel?

I just want to grab a stats structure (well-aligned 32 and 64-bit counters
and fixed-length strings) for a pktgen interface.

Can you do this with seq-files somehow?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

