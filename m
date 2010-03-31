From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH v3 04/12] l2tp: Add ppp device name to L2TP ppp session
 data
Date: Wed, 31 Mar 2010 08:43:09 +0100
Message-ID: <4BB2FD0D.1080105@katalix.com>
References: <20100330161725.9628.69994.stgit@bert.katalix.com>	<20100330161746.9628.40723.stgit@bert.katalix.com> <20100330092914.4f3e9ed3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:51835 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756974Ab0CaHnS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 03:43:18 -0400
In-Reply-To: <20100330092914.4f3e9ed3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Tue, 30 Mar 2010 17:17:46 +0100
> James Chapman <jchapman@katalix.com> wrote:
> 
>> When dumping L2TP PPP sessions using /proc/net/l2tp, get
>> the assigned PPP device name from PPP using ppp_dev_name().
>>
>> Signed-off-by: James Chapman <jchapman@katalix.com>
>> Reviewed-by: Randy Dunlap <randy.dunlap@oracle.com>
>>
> 
> Why is this a necessary API?
> Why not put it in debugfs if just a debugging tool?

With the original driver (merged in 2.6.23), some people use horrible
hacks in scripts to derive info about their L2TP connections from /proc.
So I was reluctant to move it to debugfs in the new driver. If it is ok
to move an existing /proc file to debugfs, I'm happy to do so. People
should obtain such info from their L2TP userspace daemon, or through
netlink anyway.


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

