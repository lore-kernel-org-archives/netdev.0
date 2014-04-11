From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 2/2] macvlan: Move broadcasts into a work queue
Date: Fri, 11 Apr 2014 09:20:18 -0700
Message-ID: <53481642.9040008@candelatech.com>
References: <20140407142334.GA28814@gondor.apana.org.au> <53442868.3090701@candelatech.com> <20140408172349.GA7147@gondor.apana.org.au> <20140410.214023.849284639345029049.davem@davemloft.net> <20140411015906.GB31251@gondor.apana.org.au> <1397182170.16584.75.camel@edumazet-glaptop2.roam.corp.google.com> <20140411021300.GA31748@gondor.apana.org.au> <063D6719AE5E284EB5DD2968C1650D6D0F6F5DE1@AcuExch.aculab.com> <5348144D.9050607@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "'Herbert Xu'" <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:42692 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759618AbaDKQU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 12:20:27 -0400
In-Reply-To: <5348144D.9050607@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2014 09:11 AM, Ben Greear wrote:
> On 04/11/2014 01:45 AM, David Laight wrote:
>>>> ARP filter would require to inspect the queried IPv4 address, and
>>>> macvlan do not currently have a list of IPv4 addresses per port.
>>>
>>> Indeed.  Thanks for snapping us out of our collective daydream :)
>>
>> You could save the info from ARP responses.
>>
>> Whether you want that much layer-breaking is another matter.
>> By the sound of it, it might be worth doing the deep packet
>> inspection at startup.
> 
> I wouldn't want to keep history, but in most network scenarios,
> having only the interface with the matching MAC answer the APR is good
> enough.

I meant to say matching IP instead of matching MAC.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
