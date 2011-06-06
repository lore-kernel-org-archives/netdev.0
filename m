From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: [RFC] should we care of COMPAT mode in bridge ?
Date: Mon, 06 Jun 2011 22:31:55 +0200
Message-ID: <m28vtevgzo.fsf@igel.home>
References: <1307389540.2642.3.camel@edumazet-laptop>
	<20110606.130309.847468074358617705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:35853 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756071Ab1FFUb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 16:31:58 -0400
In-Reply-To: <20110606.130309.847468074358617705.davem@davemloft.net> (David
	Miller's message of "Mon, 06 Jun 2011 13:03:09 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 06 Jun 2011 21:45:40 +0200
>
>> While trying Alexander Holler patch, I found a 32bit brctl program was
>> not able to work on a 64bit kernel. So I had to switch to another
>> machine for my tests.
>> 
>> brctl addbr mybridge
>> ->
>> socket(PF_FILE, SOCK_STREAM, 0)         = 3
>> ioctl(3, SIOCSIFBR, 0xffd509c0)         = -1 EINVAL (Invalid argument)
>> 
>> Should we care or not ?
>
> I think we should make an effort to fix this.

OTOH, the SIOCSIFBR and SIOCGIFBR ioctls are obsoleted by the
SIOCBRADDBR, SIOCBRDELBR, SIOCBRADDIF, SIOCBRDELIF ioctls and bridge
sysfs files (which have no compat issues).

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
