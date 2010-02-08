From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC]: xfrm by mark
Date: Mon, 08 Feb 2010 16:00:33 +0100
Message-ID: <4B702711.6080800@trash.net>
References: <1265567522.3688.27.camel@bigi>  <4B701204.6000106@trash.net> <1265641110.3688.45.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	=?ISO-8859-15?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36431 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389Ab0BHPAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 10:00:39 -0500
In-Reply-To: <1265641110.3688.45.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Mon, 2010-02-08 at 14:30 +0100, Patrick McHardy wrote:
> 
>> If you simply add the mark to the lookup key, it will break
>> existing setups already using marks. I'd suggest to also add
>> a mask which is initialized to 0 when no mark attribute is
>> present.
> 
> Good point - better safe than sorry (especially after the havoc
> that ingress mark caused;->)
> 
> Would it be easier to just add a global sysctl with default being
> "dont use marks"? It will be less memory use than a 32-bit mask per
> mark..

I'd prefer masks since the mark size is pretty small and its already
quite complicated to fit everything in 32 bit in complex setups.
We also support masks everywhere else (I believe) for mark values
nowadays.
