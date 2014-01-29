From: Andre Naujoks <nautsch2@gmail.com>
Subject: Re: [PATCH stable 3.11+] can: bcm: add skb destructor
Date: Wed, 29 Jan 2014 09:47:54 +0100
Message-ID: <52E8C03A.4030906@gmail.com>
References: <52E833ED.4080006@hartkopp.net>	<1390953066.28432.26.camel@edumazet-glaptop2.roam.corp.google.com>	<52E8B053.2030808@gmail.com> <20140128.234630.1768378245126172951.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, socketcan@hartkopp.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:61541 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbaA2Ir5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 03:47:57 -0500
Received: by mail-ea0-f173.google.com with SMTP id d10so722596eaj.18
        for <netdev@vger.kernel.org>; Wed, 29 Jan 2014 00:47:55 -0800 (PST)
In-Reply-To: <20140128.234630.1768378245126172951.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.01.2014 08:46, schrieb David Miller:
> From: Andre Naujoks <nautsch2@gmail.com>
> Date: Wed, 29 Jan 2014 08:40:03 +0100
> 
>> Even if this is a bug in the CAN BCM implementation. Your "fix" just
>> enabled a user space application to shut down any machine with a kernel
>> containing the BUG_ON patch.
> 
> Rather, he detected a potential stray pointer reference to freed data
> that was caused by the CAN code which would difficult if not
> impossible to detect otherwise.
> 
> That's even more dangerous, and you should be thanking him.

"potential" is the keyword here. But its a definite kernel crash as it
is right now with a standard use case for the BCM.

Don't get me wrong. If there are bugs in the code, they should be fixed,
but I don't think breaking a working (even if flawed) part of the kernel
is the right thing to do here.

Regards
  Andre

> 
