From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 4/5] udp: memory limitation by using udp_mem
Date: Fri, 16 Nov 2007 21:52:16 -0500
Message-ID: <473E5760.3020802@redhat.com>
References: <473CBDAD.1010708@redhat.com> <473CBF16.8040001@redhat.com> <20071115.152353.100893781.davem@davemloft.net> <20071116021241.GD32509@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, satoshi.oshima.fk@hitachi.com,
	billfink@mindspring.com, andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46256 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753686AbXKQCxQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 21:53:16 -0500
In-Reply-To: <20071116021241.GD32509@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, Nov 15, 2007 at 03:23:53PM -0800, David Miller wrote:
>> We don't have tests all over the place to see if a socket is TCP or
>> DCCP or SCTP in order to implement memory accounting there, because we
>> did it for connection oriented protocols cleanly, seperating things
>> via callbacks etc.
>>
>> I would like to see the datagram memory accounting work similarly.
> 
> I agree.  In fact if we adopt some of the conventions used by
> stream protocols such as the use of sk_forward_alloc, we should
> be able to share code with TCP accounting too.
> 
> As it is every packet updates a global counter, using sk_forward_alloc
> would mean that for most packets you only update a per-socket counter
> which then would feed into the global counter at points such as socket
> creation and destruction.
> 
> Cheers,

Hello,

I appreciate your comments.

I understood that memory accounting code should avoid special protocols checks.
Then, I'll improve this part in next patch set.

Many thanks,
Hideo

-- 
Hitachi Computer Products (America) Inc.

