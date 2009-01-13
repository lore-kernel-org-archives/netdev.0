From: Speedster <speedster@haveacry.com>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
 2.6.27
Date: Tue, 13 Jan 2009 19:50:33 +0900
Message-ID: <496C71F9.4030803@haveacry.com>
References: <e7c4531f0901081558n429f7275w717774dbe9ccd895@mail.gmail.com> <20090109031408.GB11336@gondor.apana.org.au> <20090109115515.GA12486@gondor.apana.org.au> <20090109120455.GB12486@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Dykstra <john.dykstra1@gmail.com>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvi?= =?ISO-8859-1?Q?nen?=
	<ilpo.jarvinen@helsinki.fi>, Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosted03.westnet.com.au ([203.10.1.215]:60373 "EHLO
	hosted03.westnet.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbZAMKun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 05:50:43 -0500
In-Reply-To: <20090109120455.GB12486@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Fri, Jan 09, 2009 at 10:55:15PM +1100, Herbert Xu wrote:
>> It turns out that even though we have sysctl's that's supposed
>> to control pppoe/vlan processing, they don't actually work.
>>
>> This patch should make them work.
> 

<snip>

> Cheers,

I can confirm this resolves the issue. I have compiled a 2.6.28 kernel 
with Herbert's patches and I can now use the packaged 2.6.27-9 kernel in 
the Ubuntu guest.

Cheers
Dean
