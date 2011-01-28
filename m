From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH] ipsec: fix IPv4 AH alignment on 32 bits
Date: Fri, 28 Jan 2011 09:51:40 +0100
Message-ID: <4D42839C.3050401@6wind.com>
References: <20110128045108.GA8351@gondor.apana.org.au>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	christophe.gouault@6wind.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58630 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755086Ab1A1Ivp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 03:51:45 -0500
Received: by wwa36 with SMTP id 36so3111085wwa.1
        for <netdev@vger.kernel.org>; Fri, 28 Jan 2011 00:51:43 -0800 (PST)
In-Reply-To: <20110128045108.GA8351@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/01/2011 05:51, Herbert Xu wrote:
> David Miller<davem@davemloft.net>  wrote:
>>
>> We cannot just start rejecting the old 8-byte alignment on input if
>> Linux has been using an 8-byte alignment since day one.
>>
>> If you want this change to be considered seriously, you need to relax
>> the AH4 input check.
>
> I second your sentiment.  However, in this particular case it
> would appear that our old implementation was also overly strict
> in rejecting 32-bit alignment so even if we relax it now it still
> wouldn't work with an old implementation once we reduce the padding
> on output (unless you traffic was one-way only).
Yes, this was my initial problem.

>
> So perhaps an SA configuration flag is needed?
I agree. If David is ok, I will update the patch.


Regards,
Nicolas
