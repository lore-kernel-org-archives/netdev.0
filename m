From: Jaco Kroon <jaco@kroon.co.za>
Subject: Re: [PATCH] infinite recursion in netlink
Date: Thu, 26 Apr 2007 00:21:50 +0200
Message-ID: <462FD47E.8020502@kroon.co.za>
References: <20070425183856.GA6028@ms2.inr.ac.ru> <20070425195941.GA11699@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, davem@davemloft.net,
	security@kernel.org, netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp03.isdsl.net ([196.26.208.195]:61736 "EHLO smtp03.isdsl.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993118AbXDYWx5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2007 18:53:57 -0400
In-Reply-To: <20070425195941.GA11699@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg KH wrote:
> On Wed, Apr 25, 2007 at 10:38:56PM +0400, Alexey Kuznetsov wrote:
>> Hello!
>>
>> Reply to NETLINK_FIB_LOOKUP messages were misrouted back to kernel,
>> which resulted in infinite recursion and stack overflow.
>>
>> The bug is present in all kernel versions since the feature appeared.
> 
> Any hint on when this feature appeared so that we can notify the distros
> for older releases?
> 
> thanks,

2.6.13 if I'm not mistaken, confirmed on debian testing by Simeon 
Miteff.  From man 7 netlink:

NETLINK_W1 and NETLINK_FIB_LOOKUP appeared in Linux 2.6.13.

Jaco
