From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next-2.6 PATCH 1/7] xfrm: introduce basic mark infrastructure
Date: Mon, 15 Feb 2010 18:06:17 +0100
Message-ID: <4B797F09.5050207@trash.net>
References: <xfrm-mark-net-next>	 <1266160732-946-1-git-send-email-hadi@cyberus.ca>	 <1266160732-946-2-git-send-email-hadi@cyberus.ca>	 <4B796B70.2050102@trash.net> <1266253235.6776.90.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, herbert@gondor.apana.org.au,
	davem@davemloft.net, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64731 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755758Ab0BORGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 12:06:20 -0500
In-Reply-To: <1266253235.6776.90.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Mon, 2010-02-15 at 16:42 +0100, Patrick McHardy wrote:
> 
> 
>> This doesn't look right. A mark value of 0 with a mask of ~0 won't
>> be properly dumped. I think this should check for (m->m | m->v).
>>
> 
> Good point, thanks. I will make that change;
> 
> Rest of patches look reasonable?

I couldn't spot any further problems so far.

One related feature which would be nice to have is the ability
to use marks for xfrm tunnel routing. But I'm not sure we can
do this in a backwards compatible way.
