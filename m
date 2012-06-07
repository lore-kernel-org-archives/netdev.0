From: Ben Greear <greearb@candelatech.com>
Subject: Socket send-buffer auto-sizing
Date: Thu, 07 Jun 2012 10:59:29 -0700
Message-ID: <4FD0EC01.3020300@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60095 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932414Ab2FGR7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 13:59:30 -0400
Received: from [192.168.100.111] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id q57HxTuC032557
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2012 10:59:29 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm continuing to test one-way tcp streams in 3.5.0-rc1 on
a wifi network.

When I do not specify a send buffer size, and thus use the kernel
defaults, max speed is about 77Mbps.

When I specify 512KB send-buffer, I get speeds up to 185Mbps.

When set to 1MB, I get about 198Mbps (and setting higher does not
increase the throughput after this).

This is without any 'delack' patches applied.

My question is:  Should the kernel auto-tuner work better?

I seem to recall a comments from some years ago that applications
should no longer attempt to tune send/recv buffers because the kernel
was smart enough to get it at least mostly right.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
