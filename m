From: robert@herjulf.net
Subject: Re: [PATCH 00/14] pktgen update for net-next (2.6.32)
Date: Tue, 8 Sep 2009 17:41:05 +0200
Message-ID: <19110.31505.134937.813631@gargle.gargle.HOWL>
References: <20090827235506.624381734@vyatta.com>
	<19110.17776.721680.242313@gargle.gargle.HOWL>
	<Pine.LNX.4.64.0909081409210.20285@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert@herjulf.net, Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>,
	netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atthis.its.uu.se ([130.238.7.58]:48770 "EHLO atthis.its.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753240AbZIHNdz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Sep 2009 09:33:55 -0400
In-Reply-To: <Pine.LNX.4.64.0909081409210.20285@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 8 Sep 2009, robert@herjulf.net wrote:
>>
>> Sending different pkt-sizes at maxrate using one CPU-core (of eight)
>> with ixgbe driver and Intel's 82598 chip.
>>
>>      w. patch
>> 64    4761904    3846153

>I can also measure a performance improvement.

> Generator machine, AMD Phenom 9950 quad core, using a 10GbE Intel 82599 
> NIC (6 port 10GbE from Hotlava Systems Inc.).

> With patches:
> -------------
> tx_pkt_sz: 64  TX-pps: 9426724

Impressive. 82599 seems fast. Didn't you report even higher number
with other CPU's?

Cheers
					--ro
