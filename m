From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] [IPSEC]: Add async resume support on input
Date: Wed, 14 Nov 2007 10:05:51 +0100
Message-ID: <473ABA6F.5000004@trash.net>
References: <20071113.214609.04000914.davem@davemloft.net>	<20071114062758.GA11173@gondor.apana.org.au>	<20071114062834.GB11173@gondor.apana.org.au> <20071113.223356.216207937.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38438 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752839AbXKNJGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 04:06:01 -0500
In-Reply-To: <20071113.223356.216207937.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 14 Nov 2007 14:28:34 +0800
> 
>> [IPSEC]: Add async resume support on input
>>
>> This patch adds support for async resumptions on input.  To do so, the
>> transform would return -EINPROGRESS and subsequently invoke the function
>> xfrm_input_resume to resume processing.
>>
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Also applied to net-2.6.25, thanks.
> 
> I'll work on integrating Patrick's NF_INET_* patch next.


I'm rebasing my netfilter tree to net-2.6.25, so unless you're
already working on this, I can take care of that.
