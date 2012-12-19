From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP delayed ACK heuristic
Date: Wed, 19 Dec 2012 10:39:37 -0800
Message-ID: <50D209E9.2000504@hp.com>
References: <270756364.27707018.1355842632348.JavaMail.root@redhat.com> <2088500005.27728019.1355843484620.JavaMail.root@redhat.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70F4@saturn3.aculab.com> <1355900436.6665.16.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org,
	Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Thomas Graf <tgraf@redhat.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:4613 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980Ab2LSSjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 13:39:40 -0500
In-Reply-To: <1355900436.6665.16.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/18/2012 11:00 PM, Cong Wang wrote:
> On Tue, 2012-12-18 at 16:39 +0000, David Laight wrote:
>> There are problems with only implementing the acks
>> specified by RFC1122.
>
> Yeah, the problem is if we can violate this RFC for getting better
> performance. Or it is just a no-no?
>
> Although RFC 2525 mentions this as "Stretch ACK Violation", I am still
> not sure if that means we can violate RFC1122 legally.

The term used in RFC1122 is "SHOULD" not "MUST."  Same for RFC2525 when 
it talks about "Stretch ACK Violation."   A TCP stack may have behaviour 
which differs from a SHOULD so long as there is a reasonable reason for it.

rick jones
