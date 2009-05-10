From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipconfig: handle case of delayed DHCP server
Date: Sun, 10 May 2009 01:08:21 -0700 (PDT)
Message-ID: <20090510.010821.00122250.davem@davemloft.net>
References: <4A049C6B.9070000@nortel.com>
	<20090508.143947.207466029.davem@davemloft.net>
	<m17i0pwg0w.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cfriesen@nortel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47326
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750833AbZEJIIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2009 04:08:25 -0400
In-Reply-To: <m17i0pwg0w.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 10 May 2009 00:53:03 -0700

> David Miller <davem@davemloft.net> writes:
> 
>> From: "Chris Friesen" <cfriesen@nortel.com>
>> Date: Fri, 08 May 2009 14:56:11 -0600
>>
>>> 
>>> +	/* Is it a reply for the device we are configuring? */
>>> +	if (b->xid != ic_dev_xid) {
>>> +		if (net_ratelimit())
>>> + printk(KERN_ERR "DHCP/BOOTP: Ignoring delayed packet \n");
>>> +		goto drop_unlock;
>>
>> Please don't use such odd indentation for this printk
>> statement.
> 
> Weird it looked ok in my mailer 3 tabs in, and out to coloumn 82.  Dave someting
> word wrap it for you?

I hope it's not my arch-nemesis, format=flowed :-/
