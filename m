From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Fri, 4 Dec 2015 21:45:09 -0800
Message-ID: <566279E5.9070500@gmail.com>
References: <1449158374.11080.456996721.69F803D7@webmail.messagingengine.com>
 <CALx6S342OMLB6s7LcmnZP1rnYNUs345Dy1gjYX3JUKqqB_waPA@mail.gmail.com>
 <1449259145.6236.458303617.55CF2C4E@webmail.messagingengine.com>
 <20151204.150633.1744714566987717806.davem@davemloft.net>
 <CAKgT0UepW=VehhXncrAM=tvqrVDD_KOdVJBpwEU+hYTAdMz_dg@mail.gmail.com>
 <CALx6S36Y4fP9a6U40My+kuhik5THPOjHNYfRrVe8Szte03K7Ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	John Linville <linville@tuxdriver.com>,
	Jesse Gross <jesse@kernel.org>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35489 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950AbbLEFpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 00:45:14 -0500
Received: by pacej9 with SMTP id ej9so97272307pac.2
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2015 21:45:13 -0800 (PST)
In-Reply-To: <CALx6S36Y4fP9a6U40My+kuhik5THPOjHNYfRrVe8Szte03K7Ew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/2015 04:53 PM, Tom Herbert wrote:
>> I actually tried to push the generic checksum idea for fm10k back
>> during hardware development but ended up losing that battle.  The
>> problem is you have to have some customer willing to spend the cash in
>> order to get a feature, and the fact is nobody other than Tom has been
>> pushing for this.
>
> Very well, it is true that I only represent one user of networking
> protocols, grant it a very large one. I will shut up now. If other
> USERS want to chime in on what is best I'll certainly listen.

Tom,

I'm sorry, but I have a hard time believing you are actually 
representing a large user here.  By large user I assume you are implying 
Facebook?  I agree that your point is very valid on the merits of the 
1's compliment checksum likely being a useful feature, but I just think 
you are going about this the wrong way as obstructing things like this 
does little to impact hardware design decisions.

If we want to win over the manufacturers we would have to speak with 
money as they aren't going to make something unless they are convinced 
they can sell it.  Simply insisting we want some feature doesn't do much 
without the customer demand to back it up.  So, unless you are telling 
me Facebook is going to let this feature influence a purchasing decision 
in the future, the argument is B.S.

Not having this feature has to in some way impact sales.  You need to 
make the 1's compliment checksum a check box type item that if the part 
doesn't have the customer won't buy.  If you were to come up with some 
sort of data demonstrating the need for the feature and were to 
associate it with something such as Open Compute then you would start to 
go a long way towards winning over consumers that they need the feature 
and as a result convincing the manufacturers that they have to provide it.

- Alex
