From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 2/5] accounting unit and variable
Date: Thu, 15 Nov 2007 16:37:27 -0500
Message-ID: <473CBC17.7060608@redhat.com>
References: <47264F3E.3080306@redhat.com> <20071109123420.GD27984@gondor.apana.org.au> <473A6B11.7090208@redhat.com> <20071113.195549.181119456.davem@davemloft.net> <473B150A.8050208@redhat.com> <473B852B.3010107@redhat.com> <20071115010909.GA21193@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	satoshi.oshima.fk@hitachi.com, andi@firstfloor.org,
	shemminger@linux-foundation.org, johnpol@2ka.mipt.ru,
	yoshfuji@linux-ipv6.org, yumiko.sugita.yf@hitachi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52296 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756270AbXKOVmC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 16:42:02 -0500
In-Reply-To: <20071115010909.GA21193@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Wed, Nov 14, 2007 at 06:30:51PM -0500, Hideo AOKI wrote:
>> +#define SK_DATAGRAM_MEM_QUANTUM ((unsigned int)PAGE_SIZE)
>> +
>> +static inline int sk_datagram_pages(int amt)
>> +{
>> +	/* Cast to unsigned as an optimization, since amt is always 
>> positive. */
>> +	return DIV_ROUND_UP((unsigned int)amt, SK_DATAGRAM_MEM_QUANTUM);
>> +}
>> +
> 
> Thanks, this looks OK to me.

Hello,

Thank you for reviewing. Then, I'll send take 8 patch set later.

Regards,
Hideo

-- 
Hitachi Computer Products (America) Inc.


