From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net-next] tcp: avoid tx starvation by SYNACK packets
Date: Sat, 23 Jun 2012 00:34:53 -0700
Message-ID: <CAGK4HS8Hae_4sNQeGXGc4ocK1-2DVtCUdBAPj7+DY_iF6-2zOA@mail.gmail.com>
References: <1338501397.2760.1395.camel@edumazet-glaptop>
	<CAA93jw755V9kJ=P1gFsG2oafddhsebzfT3DuY5NX59GPpheOZg@mail.gmail.com>
	<1338615992.2760.1665.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dave Taht <dave.taht@gmail.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:40544 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520Ab2FWHey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2012 03:34:54 -0400
Received: by obbuo13 with SMTP id uo13so3133391obb.19
        for <netdev@vger.kernel.org>; Sat, 23 Jun 2012 00:34:53 -0700 (PDT)
In-Reply-To: <1338615992.2760.1665.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1 June 2012 22:46, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2012-06-01 at 18:28 -0700, Dave Taht wrote:
>> On Thu, May 31, 2012 at 2:56 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > From: Eric Dumazet <edumazet@google.com>
>> >
>> > pfifo_fast being the default Qdisc, its pretty easy to fill it with
>> > SYNACK (small) packets while host is under SYNFLOOD attack.
>> >
>> > Packets of established TCP sessions are dropped and host appears almost
>> > dead.
>> >
>> > Avoid this problem assigning TC_PRIO_FILLER priority to SYNACK
>> > generated in SYNCOOKIE mode, so that these packets are enqueued into
>> > pfifo_fast band 2.
>> >
>> > Other packets, queued to band 0 or 1 are dequeued before any SYNACK
>> > packets waiting in band 2.
>>

This  patch ([PATCH net-next] tcp: avoid tx starvation by SYNACK
packets)  is neither in net/net-next trees nor on patchwork. Maybe it
was missed since it was sent during the merge window. Is this not
needed anymore or is it being tested currently?

Thanks,
Vijay
