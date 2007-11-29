From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] [IPSEC]: Reinject v6 packet on input instead	of	calling
 netfilter
Date: Thu, 29 Nov 2007 22:21:05 +0100
Message-ID: <474F2D41.60707@trash.net>
References: <1196369551.4437.24.camel@localhost>	 <474F275D.3030401@trash.net> <1196370761.4437.28.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56871 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302AbXK2VVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 16:21:36 -0500
In-Reply-To: <1196370761.4437.28.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Thu, 2007-29-11 at 21:55 +0100, Patrick McHardy wrote:
>   
>> jamal wrote:
>>
>> [ can't quote because non-inline attachment ]
>>     
>
> Evolution seems to have whitespace issues everytime i inlined the
> attachment; and Dave has been able to tolerate me doing this so far.
> I have just read it in
>   

I used to work fine for me as well, the Debian switch to icedove
broke it. Never mind, I'm sure its going to get fixed some day :)

>   
>> I think Yoshifuji had some objections to this because extension
>> headers will be processed twice.
>>     
>
> ah, i missed that part. Could you point to a specific portion?
>   

http://lists.openwall.net/netdev/2007/10/16/88
> I wouldnt mind just ipv4 going in - but that would be lacking
> consistency. Is there anything that can be done to get the extension
> headers to be processed only once?
>   

I would prefer to keep things consistent between IPv4 and IPv6. Not
sure if anything could be done, perhaps we could keep the necessary
parts of the IP6CB and skip parsing up to the ESP nexthdr.

