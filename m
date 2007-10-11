From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: authenc compile warnings in current net-2.6.24
Date: Thu, 11 Oct 2007 18:38:35 +0200
Message-ID: <470E518B.1020006@hartkopp.net>
References: <470D11B1.2040207@hartkopp.net> <20071010195337.GA21597@Chamillionaire.breakpoint.cc> <20071010.162528.91758998.davem@davemloft.net> <20071011105806.GA28862@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Sebastian Siewior <netdev@ml.breakpoint.cc>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:45615 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506AbXJKQii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 12:38:38 -0400
In-Reply-To: <20071011105806.GA28862@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sebastian Siewior wrote:
> * David Miller | 2007-10-10 16:25:28 [-0700]:
>
>   
>> From: Sebastian Siewior <netdev@ml.breakpoint.cc>
>> Date: Wed, 10 Oct 2007 21:53:37 +0200
>>
>>     
>>> * Oliver Hartkopp | 2007-10-10 19:53:53 [+0200]:
>>>
>>>       
>>>> CC [M] crypto/authenc.o
>>>> crypto/authenc.c: In function ?crypto_authenc_hash?:
>>>> crypto/authenc.c:88: warning: ?cryptlen? may be used uninitialized in this 
>>>> function
>>>> crypto/authenc.c:87: warning: ?dst? may be used uninitialized in this 
>>>> function
>>>> crypto/authenc.c: In function ?crypto_authenc_decrypt?:
>>>> crypto/authenc.c:163: warning: ?cryptlen? may be used uninitialized in this 
>>>> function
>>>> crypto/authenc.c:163: note: ?cryptlen? was declared here
>>>> crypto/authenc.c:162: warning: ?src? may be used uninitialized in this 
>>>> function
>>>> crypto/authenc.c:162: note: ?src? was declared here
>>>>
>>>> do you already know these warnings?
>>>>         
>>> Those warnings are looking like a compiler bug to me.
>>>       
>> To be honest I don't know of any compiler which commits enough
>> flow variable analysis to support doing %100 accurate warnings
>> in situations like this.
>>     
>
> gcc (GCC) 4.1.2 (Gentoo 4.1.2) did not produce any warnings in this
> case.
>
>   

Hi Sebasian,

my gcc was the lastest Debian unstable one:

gcc -v

Using built-in specs.
Target: i486-linux-gnu
Configured with: ../src/configure -v 
--enable-languages=c,c++,fortran,objc,obj-c++,treelang --prefix=/usr 
--enable-shared --with-system-zlib --libexecdir=/usr/lib 
--without-included-gettext --enable-threads=posix --enable-nls 
--with-gxx-include-dir=/usr/include/c++/4.2 --program-suffix=-4.2 
--enable-clocale=gnu --enable-libstdcxx-debug --enable-mpfr 
--enable-targets=all --disable-werror --enable-checking=release 
--build=i486-linux-gnu --host=i486-linux-gnu --target=i486-linux-gnu
Thread model: posix
gcc version 4.2.1 (Debian 4.2.1-5)

Regards,
Oliver


