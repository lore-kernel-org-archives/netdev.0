From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next 2/8] bonding: Check return of dev_set_promiscuity/allmulti
Date: Mon, 23 Jun 2008 13:13:10 +0200
Message-ID: <485F8546.9030209@trash.net>
References: <485AFFD2.4090304@cn.fujitsu.com> <20080619.190724.264140435.davem@davemloft.net> <485D462E.3060003@cisco.com> <485EFE06.7040104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joe Eykholt <jeykholt@cisco.com>,
	David Miller <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org, fubar@us.ibm.com
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45624 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754083AbYFWLNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 07:13:14 -0400
In-Reply-To: <485EFE06.7040104@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> Joe Eykholt said the following on 2008-6-22 2:19:
>> If netdev->promiscuity overflows, shouldn't there be a WARN_ON or BUG_ON
>> that catches that?  Either someone forgot to clean up, or much less likely,
>> the counter needs to be widened.  It isn't necessarily the current caller's
>> fault, but some indication of the problem is better than nothing.
>>
> 
> If promiscuity overflows, dev_set_promiscuity will printk(KERN_WARNING) now.
> Compare to that, WARN_ON has more information about modules info and dump stack.
> But I think printk has enough information to indicate the problem and we
> don't need WARN_ON.
> How do you think?


WARN_ON doesn't provide any useful information here, if the counter
overflowed, its because *something else* increased it by too much.


