From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 2/5] accounting unit and variable
Date: Tue, 13 Nov 2007 22:27:13 -0500
Message-ID: <473A6B11.7090208@redhat.com>
References: <47264E2D.4080109@redhat.com> <47264F3E.3080306@redhat.com> <20071109123420.GD27984@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43681 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755597AbXKND25 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 22:28:57 -0500
In-Reply-To: <20071109123420.GD27984@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Herbert Xu wrote:
> On Mon, Oct 29, 2007 at 05:23:10PM -0400, Hideo AOKI wrote:
>>  
>> +#define SK_DATAGRAM_MEM_QUANTUM ((int)PAGE_SIZE)
>> +
>> +static inline int sk_datagram_pages(int amt)
>> +{
>> +	return DIV_ROUND_UP(amt, SK_DATAGRAM_MEM_QUANTUM);
>> +}
> 
> Does this really have to be int? Unsigned would let the compiler
> optimise this to a simple shift.

Thank you for the comment.

This inline function is used to calculate the first argument of atomic_add()
and atomic_sub(). Since the argument is int, I believe that using int is
better than using unsigned int.

Best regards,
Hideo

--
Hitachi Computer Products (America) Inc.
