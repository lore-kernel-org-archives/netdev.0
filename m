From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH v3 04/12] l2tp: Add ppp device name to L2TP ppp session
 data
Date: Thu, 01 Apr 2010 09:59:48 +0100
Message-ID: <4BB46084.5030105@katalix.com>
References: <4BB2FD0D.1080105@katalix.com>	<20100331160811.16351eb7@s6510>	<4BB4490F.8090406@katalix.com> <20100401.003459.88028238.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:38528 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754198Ab0DAI77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Apr 2010 04:59:59 -0400
In-Reply-To: <20100401.003459.88028238.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: James Chapman <jchapman@katalix.com>
> Date: Thu, 01 Apr 2010 08:19:43 +0100
> 
>> There might be thousands of L2TP sessions in some setups. Populating
>> sysfs with a link for each of those sessions isn't practical. The
>> existing /proc file dumps its info as a single text file for this
>> reason. I'd also like to provide the device name in the session netlink
>> message, which is the interface used by l2tp userspace, so I need a
>> kernel API to retrieve the device name from ppp.
> 
> Scalability concerns are also another reason _not_ to use
> procfs.
> 
> Use netlink or similar, which can dump with filtering and
> proper queueing.

See previous reply to Eric. The original /proc API was originally
intended for debug, but users have been using it in hacky scripts
instead of using proper socket interfaces to get the data they need. So
I'm proposing to retain the existing proc file for compatibility but put
other (new) driver-private debug info into debugfs.


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

