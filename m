From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 19/24] [IPSEC]: Merge most of the output path
Date: Wed, 14 Nov 2007 10:14:27 +0100
Message-ID: <473ABC73.30807@trash.net>
References: <E1Ipla8-0001IO-00@gondolin.me.apana.org.au>	<4732F1B1.204@trash.net>	<20071108112921.GB16688@gondor.apana.org.au> <20071114.010722.141237256.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38607 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752954AbXKNJOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 04:14:38 -0500
In-Reply-To: <20071114.010722.141237256.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 8 Nov 2007 19:29:21 +0800
> 
>> On Thu, Nov 08, 2007 at 12:23:29PM +0100, Patrick McHardy wrote:
>>> We have a few places that go though the trouble of selecting the
>>> "correct" hook value for the address family, even though the numerical
>>> values are identical. How about we just get rid of the different
>>> naming and use NF_INET_... for both IPv4 and IPv6?
>> Nice work! Thanks Patrick.
> 
> Yeah I like it too, applied to net-2.6.25
> 
> I had to do some minor rediffing to make it go in cleanly after
> Herbert's work, so I'm doing some build testing before I push this bit
> onto kernel.org


Thanks Dave. As luck would have it, my HIFN card should arrive
within the next few hours, so I'll try to convert esp over to
async crypto and give this all some good testing :)

