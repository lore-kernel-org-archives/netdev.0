From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] tcp: introduce TCPSpuriousRtxHostQueues SNMP
 counter
Date: Thu, 18 Apr 2013 10:45:10 -0700
Message-ID: <20130418104510.3624457a@nehalam.linuxnetplumber.net>
References: <1366303971.3205.62.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f41.google.com ([209.85.210.41]:44780 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753647Ab3DRRpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 13:45:41 -0400
Received: by mail-da0-f41.google.com with SMTP id p8so1374683dan.14
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 10:45:41 -0700 (PDT)
In-Reply-To: <1366303971.3205.62.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Apr 2013 09:52:51 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Host queues (Qdisc + NIC) can hold packets so long that TCP can
> eventually retransmit a packet before the first transmit even left
> the host.

I though you were use fq_codel ;-) and that wouldn't happen.
