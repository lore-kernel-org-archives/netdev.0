From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Removal of struct esp_data
Date: Tue, 22 Oct 2013 14:05:10 -0400 (EDT)
Message-ID: <20131022.140510.1879404122981800534.davem@davemloft.net>
References: <1382090945-20860-1-git-send-email-mathias.krause@secunet.com>
	<20131018.135536.686066381481925652.davem@davemloft.net>
	<20131022130822.GA26207@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mathias.krause@secunet.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753432Ab3JVSFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 14:05:11 -0400
In-Reply-To: <20131022130822.GA26207@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 22 Oct 2013 15:08:22 +0200

> On Fri, Oct 18, 2013 at 01:55:36PM -0400, David Miller wrote:
>> From: Mathias Krause <mathias.krause@secunet.com>
>> Date: Fri, 18 Oct 2013 12:09:03 +0200
>> 
>> > This series removes one level of indirection when accessing the aead
>> > crypto algorithm in ESP transforms by simply removing struct esp_data.
>> > This results in smaller code and less memory usage per xfrm state.
>> > 
>> > Please apply!
>> 
>> No objections from me, I'll let Steffen pick this up.
> 
> I'm a bit hesitating with removing the padlen field. We resisted
> several attempts to remove it in the past. It is currenly unused,
> but it provides the infrastructure for ESP padding as defined
> in RFC 4303. However, RFC 4303 recommends the use of TFC padding
> instead to conceal the actual length of the packet. So I'm not
> sure what's the actual usecase for ESP padding. I'll reconsider
> this next week when I'm back at office.

Steffen, is it really the case that we cannot add it back later if we
really need to?

Holding an unused member "just in case" for such a long time doesn't
seem very wise to me.
