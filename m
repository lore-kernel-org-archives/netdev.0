From: Gabriel C <nix.or.die@googlemail.com>
Subject: Re: [PATCH] IP_VS should depend on EXPERIMENTAL ?
Date: Fri, 20 Jul 2007 14:17:06 +0200
Message-ID: <46A0A7C2.3090006@googlemail.com>
References: <46A0A01A.7030403@googlemail.com> <Pine.LNX.4.64.0707200753300.10966@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Robert P. J. Day" <rpjday@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fonzie.hosting9000.com ([85.214.50.12]:32941 "EHLO
	fonzie.hosting9000.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757064AbXGTMSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 08:18:50 -0400
In-Reply-To: <Pine.LNX.4.64.0707200753300.10966@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert P. J. Day wrote:
> On Fri, 20 Jul 2007, Gabriel C wrote:
> 
>> Hi,
>>
>> IP_VS has :
>>
>> ..
>>
>> tristate "IP virtual server support (EXPERIMENTAL)"
>>
>> ..
>>
>> but it does not depend on EXPERIMENTAL.
>>
>>
>> Signed-off-by: Gabriel Craciunescu <nix.or.die@googlemail.com>
>>
>> ---
>>
>>  net/ipv4/ipvs/Kconfig |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/ipv4/ipvs/Kconfig b/net/ipv4/ipvs/Kconfig
>> index 09d0c3f..3c594ec 100644
>> --- a/net/ipv4/ipvs/Kconfig
>> +++ b/net/ipv4/ipvs/Kconfig
>> @@ -3,7 +3,7 @@
>>  #
>>  menuconfig IP_VS
>>  	tristate "IP virtual server support (EXPERIMENTAL)"
>> -	depends on NETFILTER
>> +	depends on NETFILTER && EXPERIMENTAL
>>  	---help---
>>  	  IP Virtual Server support will let you build a high-performance
>>  	  virtual server based on cluster of two or more real servers. This
> 
> there's maturity-level inconsistency like that in a few places, like
> when stuff is tagged as EXPERIMENTAL, but labelled as OBSOLETE:
> 
[ a lot examples ]

I know that and there are a lot more things depending on 'EXPERIMENTAL' and not having 
EXPERIMENTAL visible all over the tree but that patch I've made for the _net_ part got 
NACK'ed while your maturity idea and I rm -rf'ed all the other.

This one has a missing depends on EXPERIMENTAL while saying it is.

So *could* we please stop this maturity stuff for now ? I don't see it in .23 nor .24 if at all.

And even you get this kind changes for .24 almost a sed line will cleanup the whole tree from :

... "FOO blah (EXPERIMENTAL)" ...

so what is your problem ?

> rday

Gabriel
