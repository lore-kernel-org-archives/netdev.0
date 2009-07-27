From: Julius Volz <julius.volz@gmail.com>
Subject: Re: [PATCH] IPVS: Add handling of incoming ICMPV6_PKT_TOOBIG messages
Date: Mon, 27 Jul 2009 12:19:03 +0200
Message-ID: <43ca39800907270319r4fd42236v21ade59dc56b02da@mail.gmail.com>
References: <20090624132232.GA9633@egardia>
	 <20090724024711.GA13280@verge.net.au> <4A6937B5.3040707@gmail.com>
	 <20090726.191905.158195470.davem@davemloft.net>
	 <20090727023754.GC723@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	robert.gallagher@heanet.ie
To: Simon Horman <horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20090727023754.GC723@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 27, 2009 at 4:37 AM, Simon Horman<horms@verge.net.au> wrote=
:
> On Sun, Jul 26, 2009 at 07:19:05PM -0700, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Fri, 24 Jul 2009 06:25:25 +0200
>>
>> > I see no reference to ICMPV6_PKT_TOOBIG in this patch, so ChangeLo=
g
>> > might be misleading or uncomplete, since other ICMPV6 message type=
s
>> > (ICMPV6_DEST_UNREACH/ICMPV6_TIME_EXCEED) will also be forwarded/ha=
ndled
>> > ?
>>
>> Agreed, this commit message could use a tidy. =A0What the patch actu=
ally is
>> doing is adding the handling of ipv6 icmp messages at all.
>>
>> Simon could you clarify the commit message a bit and resubmit?
>
> Will do.

Oops, yes. For some weird reason, only the specific problem that
caused the patch was in my head when writing that commit message. Feel
free to edit it to include ICMPv6 handling for in-out packets in
general.

Julius
