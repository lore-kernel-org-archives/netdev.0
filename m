From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Add compat ioctl support for the ipv4 multicast ioctl SIOCGETSGCNT
Date: Thu, 03 Feb 2011 18:07:47 -0800
Message-ID: <m1hbcko8lo.fsf@fess.ebiederm.org>
References: <201101301326.14390.arnd@arndb.de>
	<m18vy2tfzn.fsf@fess.ebiederm.org> <201101301959.53661.arnd@arndb.de>
	<20110203.171918.28815936.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: arnd@arndb.de, netdev@vger.kernel.org, eric.dumazet@gmail.com,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52566 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753328Ab1BDCHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 21:07:55 -0500
In-Reply-To: <20110203.171918.28815936.davem@davemloft.net> (David Miller's
	message of "Thu, 03 Feb 2011 17:19:18 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Arnd Bergmann <arnd@arndb.de>
> Date: Sun, 30 Jan 2011 19:59:53 +0100
>
>> * ip multicast actually needs support for SIOCGETVIFCNT in
>>   addition to SIOCGETSGCNT to be complete.
>> * ipv6 multicast needs the same patch as ipv4 multicast for
>>   SIOCGETMIFCNT_IN6/SIOCGETSGCNT_IN6.
>> 
>> It would probably be a good idea if someone could complete the
>> work on ipv4/v6 multicast compat_ioctl, on top of your patch.
>
> Actually, on top of this, Eric's patch is buggy.

Ouch.  Thanks for catching that.

> He defines the "struct compat_sioc_sg_req" but doesn't actually
> use it.
>
> I'll fix that, then take care of the missing cases.  Thanks Arnd.

Eric
