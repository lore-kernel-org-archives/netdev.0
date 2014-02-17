From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v4 net-next 11/12] bonding: trivial: rename
 slave->jiffies to ->last_link_up
Date: Mon, 17 Feb 2014 16:15:31 +0100
Message-ID: <20140217151531.GD13038@redhat.com>
References: <1392648088-21336-1-git-send-email-vfalico@redhat.com>
 <1392648088-21336-12-git-send-email-vfalico@redhat.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6C18F7@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38232 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752014AbaBQPPo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Feb 2014 10:15:44 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6C18F7@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 17, 2014 at 03:02:36PM +0000, David Laight wrote:
>> -	unsigned long jiffies;
>> +	/* all three in jiffies */
>> +	unsigned long last_link_up;
>>  	unsigned long last_arp_rx;
>>  	unsigned long target_last_arp_rx[BOND_MAX_ARP_TARGETS];
>
>Personally I'd add _time to the member names (maybe not the last
>as that is long enough already).
>I sometimes go as far as adding the time units (eg _ms or _sec)
>just to avoid confusion when reading the code much later on.

Good idea, however current renaming follows the one used in bonding:

last_link_up, last_arp_rx (ripped from net_device, where last_rx is also
used), target_last_arp_rx, slave_last_rx() and some other. So it's somehow
consistent over all bonding and some other networking code (grepping by
last_rx yields a lot of results). And all of these are using jiffies as its
value.

I really like the general idea (to make it more readable, bonding really
lacks this part), however it's, IMO, a new patch(-set) material and doesn't
really fit in this patchset.

If you'd like to do that I would be really glad :), otherwise I'll add this
to my todo list.

Thanks a lot!

>
>	David
>
>
>
