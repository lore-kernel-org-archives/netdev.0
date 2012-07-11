From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC PATCH v2] tcp: TCP Small Queues
Date: Wed, 11 Jul 2012 08:43:20 -0700
Message-ID: <4FFD9F18.6030401@candelatech.com>
References: <CAA93jw7ywd0auqN=k2J4fLOGYMLRH+agWr4P+_CisgvRtvgJUw@mail.gmail.com>  <1340945457.29822.7.camel@edumazet-glaptop>  <1341396687.2583.1757.camel@edumazet-glaptop>  <20120709.000834.1182150057463599677.davem@davemloft.net>  <1341845722.3265.3065.camel@edumazet-glaptop>  <1341933215.3265.5476.camel@edumazet-glaptop>  <1342019518.3265.8116.camel@edumazet-glaptop>  <4FFD98EA.1040301@candelatech.com> <1342020306.3265.8129.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ycheng@google.com,
	dave.taht@gmail.com, netdev@vger.kernel.org,
	codel@lists.bufferbloat.net, therbert@google.com,
	mattmathis@google.com, nanditad@google.com, ncardwell@google.com,
	andrewmcgr@gmail.com, Rick Jones <rick.jones2@hp.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53181 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755310Ab2GKPna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 11:43:30 -0400
In-Reply-To: <1342020306.3265.8129.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/2012 08:25 AM, Eric Dumazet wrote:
> On Wed, 2012-07-11 at 08:16 -0700, Ben Greear wrote:
>
>> I haven't read your patch in detail, but I was wondering if this feature
>> would cause trouble for applications that are servicing many sockets at once
>> and so might take several ms between handling each individual socket.
>>
>
> Well, this patch has no impact for such applications. In fact their
> send()/write() will return to userland faster than before (for very
> large send())

Maybe I'm just confused.  Is your patch just mucking with
the queues below the tcp xmit queues?  From the patch description
I was thinking you were somehow directly limiting the TCP xmit
queues...

If you are just draining the tcp xmit queues on a new/faster
trigger, then I see no problem with that, and no need for
a per-socket control.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
