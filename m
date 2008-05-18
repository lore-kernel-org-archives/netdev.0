From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] [patch] bondig - arp_interval with low value => Oops.
Date: Sat, 17 May 2008 20:39:20 -0700
Message-ID: <5888.1211081960@death>
References: <482C9E73.2040202@free.fr> <482F3DF6.7080403@nuovasystems.com>
Cc: Nicolas 2P <nicolas.2p.debian@free.fr>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	linux-net@vger.kernel.org, David Miller <davem@davemloft.net>
To: Joe Eykholt <jre@nuovasystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:37143 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751267AbYERDj3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 May 2008 23:39:29 -0400
In-reply-to: <482F3DF6.7080403@nuovasystems.com> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Eykholt <jre@nuovasystems.com> wrote:

>Nicolas 2P wrote:
[...]
>> @@ -2837,7 +2837,7 @@
>> 
>>         read_lock(&bond->lock);
>> 
>> -       delta_in_ticks = (bond->params.arp_interval * HZ) / 1000;
>> +       delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval * HZ);
>
>This seems like it should be just:
>
>	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);

	Yes.  I've corrected this already in my copy (which I'll be
posting momentarily).

>Same for the other changes?

	The other two instances were correct, only the last change had
the extra "* HZ".

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
