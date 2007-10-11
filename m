From: Sebastian Siewior <netdev@ml.breakpoint.cc>
Subject: Re: authenc compile warnings in current net-2.6.24
Date: Thu, 11 Oct 2007 12:58:06 +0200
Message-ID: <20071011105806.GA28862@Chamillionaire.breakpoint.cc>
References: <470D11B1.2040207@hartkopp.net> <20071010195337.GA21597@Chamillionaire.breakpoint.cc> <20071010.162528.91758998.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: socketcan@hartkopp.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:41347 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750839AbXJKK6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 06:58:11 -0400
Content-Disposition: inline
In-Reply-To: <20071010.162528.91758998.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller | 2007-10-10 16:25:28 [-0700]:

>From: Sebastian Siewior <netdev@ml.breakpoint.cc>
>Date: Wed, 10 Oct 2007 21:53:37 +0200
>
>> * Oliver Hartkopp | 2007-10-10 19:53:53 [+0200]:
>> 
>> > CC [M] crypto/authenc.o
>> > crypto/authenc.c: In function ?crypto_authenc_hash?:
>> > crypto/authenc.c:88: warning: ?cryptlen? may be used uninitialized in this 
>> > function
>> > crypto/authenc.c:87: warning: ?dst? may be used uninitialized in this 
>> > function
>> > crypto/authenc.c: In function ?crypto_authenc_decrypt?:
>> > crypto/authenc.c:163: warning: ?cryptlen? may be used uninitialized in this 
>> > function
>> > crypto/authenc.c:163: note: ?cryptlen? was declared here
>> > crypto/authenc.c:162: warning: ?src? may be used uninitialized in this 
>> > function
>> > crypto/authenc.c:162: note: ?src? was declared here
>> >
>> > do you already know these warnings?
>> 
>> Those warnings are looking like a compiler bug to me.
>
>To be honest I don't know of any compiler which commits enough
>flow variable analysis to support doing %100 accurate warnings
>in situations like this.

gcc (GCC) 4.1.2 (Gentoo 4.1.2) did not produce any warnings in this
case.

>Since the compiler is unlikely to do so, I think we should fix
>it somehow because useless warnings just distract.
sure.

Sebastian
