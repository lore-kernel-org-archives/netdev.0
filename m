From: Daniel Schaffrath <danielschaffrath@mac.com>
Subject: Re: tcp bw in 2.6
Date: Mon, 15 Oct 2007 14:40:25 +0200
Message-ID: <2CA039DF-4BE6-453F-AB61-C3D206E6D573@mac.com>
References: <20071002005917.GB5480@bitmover.com> <E1IcfN0-0007tt-00@gondolin.me.apana.org.au> <20071002150935.GC17418@bitmover.com> <20071002154137.GD17418@bitmover.com> <20071002162534.GG17418@bitmover.com> <20071002094726.154fc619@freepuppy.rosehill>
Mime-Version: 1.0 (Apple Message framework v752.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Larry McVoy <lm@bitmover.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	torvalds@linux-foundation.org, davem@davemloft.net,
	wscott@bitmover.com, Linux NetDev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutm.mac.com ([17.148.16.70]:50042 "EHLO smtpoutm.mac.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755700AbXJOMs5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 08:48:57 -0400
In-Reply-To: <20071002094726.154fc619@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2007/10/02  , at 18:47, Stephen Hemminger wrote:

> On Tue, 2 Oct 2007 09:25:34 -0700
> lm@bitmover.com (Larry McVoy) wrote:
>
>>> If the server side is the source of the data, i.e, it's transfer  
>>> is a
>>> write loop, then I get the bad behaviour.
>>> ...
>>> So is this a bug or intentional?
>>
>> For whatever it is worth, I believed that we used to get better  
>> performance
>> from the same hardware.  My guess is that it changed somewhere  
>> between
>> 2.6.15-1-k7 and 2.6.18-5-k7.
>
> For the period from 2.6.15 to 2.6.18, the kernel by default enabled  
> TCP
> Appropriate Byte Counting. This caused bad performance on  
> applications that
> did small writes.
Stephen, maybe you can provide me with some specifics here?

Thanks a lot!!
Daniel

