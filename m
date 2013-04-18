From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net-next] tcp: introduce TCPSpuriousRtxHostQueues SNMP
 counter
Date: Thu, 18 Apr 2013 20:19:50 +0200
Message-ID: <20130418181949.GA10776@virgo.local>
References: <1366303971.3205.62.camel@edumazet-glaptop>
 <20130418104510.3624457a@nehalam.linuxnetplumber.net>
 <1366308381.3205.66.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:53747 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932077Ab3DRSTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 14:19:53 -0400
Content-Disposition: inline
In-Reply-To: <1366308381.3205.66.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2013-04-18 11:06:21 [-0700]:

>On Thu, 2013-04-18 at 10:45 -0700, Stephen Hemminger wrote:
>> On Thu, 18 Apr 2013 09:52:51 -0700
>> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> 
>> > From: Eric Dumazet <edumazet@google.com>
>> > 
>> > Host queues (Qdisc + NIC) can hold packets so long that TCP can
>> > eventually retransmit a packet before the first transmit even left
>> > the host.

Just out of curiosity: do you see effects of commit 9ad7c049 (initRTO from
3secs to 1sec) and a long standing queue? (with no path metric, rtt in
particular)

Hagen
