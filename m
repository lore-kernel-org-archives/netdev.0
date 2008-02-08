From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: ipv6_chk_acast_addr remove unused loop
Date: Fri, 08 Feb 2008 18:48:04 +0100
Message-ID: <47AC95D4.4090506@fr.ibm.com>
References: <OF1B77A186.F07F897A-ON882573E9.0060B0C5-882573E9.00614E3C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	=?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Q=?=
	 =?UTF-8?B?6Iux5piO?= <yoshfuji@linux-ipv6.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:44449 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754849AbYBHRyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 12:54:12 -0500
In-Reply-To: <OF1B77A186.F07F897A-ON882573E9.0060B0C5-882573E9.00614E3C@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens wrote:
> NACK.
> 
> Daniel,
>         This code is part of the in-kernel API for anycast, which is 
> intended
> to be the same as for multicast. By removing support for NULL there, 
> you're
> making a special case for the anycast code that isn't there in the 
> multicast
> code (can't support a NULL dev), and you really aren't buying all that 
> much for it.

I was hesitating to send this patch exactly for the reason you are 
explaining. Apparently I did the bad choice :)

Thanks.
	-- Daniel
