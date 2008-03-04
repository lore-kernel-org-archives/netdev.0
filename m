From: Brian Haley <brian.haley@hp.com>
Subject: Re: [BUG kernel 2.6.25-rc3 IPV6] ping6 -I eth0 ff02::1 causes system
 hang.
Date: Tue, 04 Mar 2008 12:49:29 -0500
Message-ID: <47CD8BA9.3050006@hp.com>
References: <20071006132601.f944f461.komurojun@nifty.com>	<20071014073658.d4352b8c.komurojun@nifty.com>	<20080302210716.69727582.komurojun-mbn@nifty.com> <20080302.212717.120106718.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: komurojun-mbn@nifty.com, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?YOSHIFUJI_Hideaki_/_=3F=3F=3F=3F?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:20734 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752549AbYCDRtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 12:49:31 -0500
In-Reply-To: <20080302.212717.120106718.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> On kernel 2.6.25-rc3, IPV6 multicast ping causes system hang
>> after sending several multicast ping packet.
>>
>>> ping6 -I eth0 ff02::1 
>> This problem does not happen on kernel 2.6.24.
>> (does not depend on NIC)
> 
> Hmm, I've never seen this on our testlab.  Anyone else?

Not here.  I tried just CONFIG_IPV6=y as well.

-Brian
