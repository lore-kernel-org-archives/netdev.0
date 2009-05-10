From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] ipconfig: handle case of delayed DHCP server
Date: Sun, 10 May 2009 00:53:03 -0700
Message-ID: <m17i0pwg0w.fsf@fess.ebiederm.org>
References: <4A049C6B.9070000@nortel.com>
	<20090508.143947.207466029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cfriesen@nortel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:49071 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbZEJHxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2009 03:53:07 -0400
In-Reply-To: <20090508.143947.207466029.davem@davemloft.net> (David Miller's message of "Fri\, 08 May 2009 14\:39\:47 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: "Chris Friesen" <cfriesen@nortel.com>
> Date: Fri, 08 May 2009 14:56:11 -0600
>
>> 
>> +	/* Is it a reply for the device we are configuring? */
>> +	if (b->xid != ic_dev_xid) {
>> +		if (net_ratelimit())
>> + printk(KERN_ERR "DHCP/BOOTP: Ignoring delayed packet \n");
>> +		goto drop_unlock;
>
> Please don't use such odd indentation for this printk
> statement.

Weird it looked ok in my mailer 3 tabs in, and out to coloumn 82.  Dave someting
word wrap it for you?

Eric
