From: Ben Greear <greearb@candelatech.com>
Subject: Re: Networking hangs when too many parallel requests are made at
 once
Date: Tue, 09 Nov 2010 14:29:24 -0800
Message-ID: <4CD9CB44.4030206@candelatech.com>
References: <AANLkTikuCj=saH34dyO6xnU-y8rWv63hJaqowZ0ACLzk@mail.gmail.com> <AANLkTinRo_ozWFCYYqanOh0YrTJ6+KadutG2j7T726dY@mail.gmail.com> <4CD99E20.4060307@candelatech.com> <AANLkTinz6C4s3wX7t6CsE2bzZ2adCoi0RAcqvpEFE2GV@mail.gmail.com> <4CD9B09B.8040906@candelatech.com> <AANLkTinu4=Ox_vA_yr7vbdbcqr4P7oS+zMX_yaXhK4E9@mail.gmail.com> <4CD9C7E2.6050909@candelatech.com> <AANLkTi=qgJcBUdhDpV8QdPPUO1o7QjZLUj07_C1B9Ygg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Luke Hutchison <luke.hutch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44998 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753497Ab0KIW31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 17:29:27 -0500
In-Reply-To: <AANLkTi=qgJcBUdhDpV8QdPPUO1o7QjZLUj07_C1B9Ygg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/2010 02:20 PM, Luke Hutchison wrote:
> On Tue, Nov 9, 2010 at 5:14 PM, Ben Greear<greearb@candelatech.com>  wrote:
>> Have you tried using a different DNS server (open-dns?), or maybe a caching
>> one one
>> your local machine?  Maybe some part of your network is throwing away
>> some of your DNS requests since you send so many at once?
>
> I have tried Google's DNS as well as Comcast's, no difference in
> effect.  Also this has been a problem when I've been in the US,
> Portugal, Germany and China, so I have probably used a range of DNS
> servers.  I have tried nscd (it's off by default) and it has the
> expected behavior: if it resolves a name before re-opening the
> browser, then that name can continue to be resolved after the network
> gets flooded.  If I ask it to resolve a domain name after the network
> is flooded, the request times out, and subsequently nscd says the
> domain name doesn't exist, even after the network link has been
> restored to normal.

If you get all names resolved with your caching name-server, can you then
open the browser tabs w/out problem?

Have you tried setting all your browser tabs to simple low-bandwidth pages (no ads being
served from various hosts, etc) to see if that works?

Maybe you are just flooding the network so hard that responses are being
dropped?

Thanks,
Ben

>
> Thanks,
> Luke


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

