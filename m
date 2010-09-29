From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCHv2 net-next-2.6 0/5] XFRM,IPv6: Removal of RH2/HAO from IPsec-protected MIPv6 traffic
Date: Wed, 29 Sep 2010 11:04:24 +0200
Message-ID: <87ocbgkjjb.fsf@small.ssi.corp>
References: <cover.1285687738.git.arno@natisbad.org>
	<20100928.133849.112575548.davem@davemloft.net>
	<87r5gdtuxv.fsf@small.ssi.corp>
	<20100928.144005.260072379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:38500 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753726Ab0I2JDc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Sep 2010 05:03:32 -0400
In-Reply-To: <20100928.144005.260072379.davem@davemloft.net> (David Miller's
	message of "Tue, 28 Sep 2010 14:40:05 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

David Miller <davem@davemloft.net> writes:

> From: arno@natisbad.org (Arnaud Ebalard)
> Date: Tue, 28 Sep 2010 23:33:16 +0200
>
>> Before following the (dumb) #ifdef path, I was about to do that but
>> worried about the penalty of the additional xfrm_state_get/put_afinfo()
>> calls on each packet I was about to add. Should I just reduce my amount
>> of coffee or is it a valid concern?
>
> Indeed, it is.
>
> Even without the concern of afinfo refcounting, this test is very
> heavy handed for the packet path.
>
> Can you make it small enough that it can reasonably be inlined?

I came up with an idea. A v3 follows; the cover letter details that.

Cheers,

a+
