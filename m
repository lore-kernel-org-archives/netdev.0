From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: IPV6_RTHDR with a type-0 routing header
Date: Thu, 20 Aug 2009 15:00:09 +0200
Message-ID: <20090820130009.GA22183@uio.no>
References: <20090820111152.GA20295@uio.no>
 <7d4abbaea1f1e17050a0e8ffe4917cb8@chewa.net>
 <20090820121820.GA21354@uio.no>
 <20090820123926.GA21858@uio.no>
 <1250772824.9489.3.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: =?utf-8?B?UsOpbWk=?= Denis-Courmont <remi@remlab.net>,
	netdev@vger.kernel.org
To: Jens Rosenboom <jens@mcbone.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:51987 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754027AbZHTNAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 09:00:11 -0400
Content-Disposition: inline
In-Reply-To: <1250772824.9489.3.camel@fnki-nb00130>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 20, 2009 at 02:53:44PM +0200, Jens Rosenboom wrote:
>> It looks like I can use destination options instead, but those don't seem to
>> be too easy to use either. The kernel seems to demand that I put eight bytes
>> of padding at the end?
>> 
>>   #define ipv6_optlen(p)  (((p)->hdrlen+1) << 3)
>> 
>> Why the +1? 
> Because that matches the definition of the hdrlen field in RFC2460.

Hm, in that case I guess it's glibc that has one too much indeed (I never
write this field).

>> FWIW, the program I try to run is at http://home.samfundet.no/~sesse/v6fun.c .
>> If I replace "len" in the setsockopt call by "len + 8", the program runs and
>> the packets get the right option attached -- but also eight padding bytes.
> ERROR 404: Not Found.

Sorry, http://home.samfundet.no/~sesse/v6opt.c

/* Steinar */
-- 
Homepage: http://www.sesse.net/
