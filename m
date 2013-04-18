From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: introduce TCPSpuriousRtxHostQueues SNMP
 counter
Date: Thu, 18 Apr 2013 11:06:21 -0700
Message-ID: <1366308381.3205.66.camel@edumazet-glaptop>
References: <1366303971.3205.62.camel@edumazet-glaptop>
	 <20130418104510.3624457a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Willem de Bruijn <willemb@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:45114 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156Ab3DRSGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 14:06:24 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz11so1773767pad.30
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 11:06:23 -0700 (PDT)
In-Reply-To: <20130418104510.3624457a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-18 at 10:45 -0700, Stephen Hemminger wrote:
> On Thu, 18 Apr 2013 09:52:51 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Host queues (Qdisc + NIC) can hold packets so long that TCP can
> > eventually retransmit a packet before the first transmit even left
> > the host.
> 
> I though you were use fq_codel ;-) and that wouldn't happen.

Remind that fq_codel drops packets at dequeue time only ;)

So TCP stack could retransmit while prior packet is still in fq_codel
queue.
