From: Patrick McHardy <kaber@trash.net>
Subject: Re: csum offload and af_packet
Date: Wed, 13 Aug 2008 13:26:22 +0200
Message-ID: <48A2C4DE.20005@trash.net>
References: <20080812005839.GC18547@gondor.apana.org.au> <200808121817.19662.netdev@axxeo.de> <20080812233753.GA29155@gondor.apana.org.au> <20080812.175532.137434164.davem@davemloft.net> <20080813010935.GA29815@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@axxeo.de,
	rusty@rustcorp.com.au, anthony@codemonkey.ws,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39638 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369AbYHML03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 07:26:29 -0400
In-Reply-To: <20080813010935.GA29815@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Aug 12, 2008 at 05:55:32PM -0700, David Miller wrote:
>
>   
>> I kind of hope that libpcap/tcpdump has been taught about auxdata
>> by now, has it? :-/
>>     
>
> Unfortunately no.  This also means that if we do do this in AF_PACKET,
> then running a packet dump on a fast outbound interface may become more
> expensive.

Actually the current CVS version understands auxdata and uses it to
reconstruct VLAN headers. CVS seems to be broken though, I can send
you a tarball with the current version if you want.
