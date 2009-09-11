From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH 00/14] pktgen update for net-next (2.6.32)
Date: Fri, 11 Sep 2009 16:29:36 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0909111616010.18616@ask.diku.dk>
References: <20090827235506.624381734@vyatta.com> <19110.17776.721680.242313@gargle.gargle.HOWL>
 <Pine.LNX.4.64.0909081409210.20285@ask.diku.dk> <19110.31505.134937.813631@gargle.gargle.HOWL>
 <Pine.LNX.4.64.0909090937550.9377@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>,
	netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: robert@herjulf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:58418 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753467AbZIKO3f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 10:29:35 -0400
In-Reply-To: <Pine.LNX.4.64.0909090937550.9377@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Sep 2009, Jesper Dangaard Brouer wrote:

> On Tue, 8 Sep 2009, robert@herjulf.net wrote:
>
>> >  With patches:
>> >  -------------
>> >  tx_pkt_sz: 64  TX-pps: 9426724
>>
>>  Impressive. 82599 seems fast. Didn't you report even higher number
>>  with other CPU's?
>
> Yes, the Core i7 is even faster... but currently I'm not using it as a 
> generator, its the router in my current setup.
>
> Once I have finished my slides and last tests for LinuxCon.  I'll run some 
> pktgen tests with the Core i7 and post the results.

Here are some quick test results:

One thing I noticed during the tests, is that using the machine during the 
tests gets very sluggy with the pktgen patches applied.

Another thing/bug that sometimes happens is that pktgen stops working and 
the ixgbe driver "says":

[  231.195624] pktgen 2.72: Packet Generator for packet performance testing.
[  233.065639] ixgbe 0000:07:00.1: master disable timed out
[  234.677107] ixgbe 0000:07:00.1: master disable timed out
[  236.284576] ixgbe 0000:07:00.1: master disable timed out
[  237.892045] ixgbe 0000:07:00.1: master disable timed out

The tests, I did complete, gave the following results:

Core i7-920 (with DDR3 at 1600Mhz)
----------------------------------
Without patches (2.6.31-rc2):

  tx_pkt_sz: 64   TX-Mbps: 5704.29    TX-pps: 11141193
  tx_pkt_sz: 128  TX-Mbps: 8415.27    TX-pps: 8218035
  tx_pkt_sz: 256  TX-Mbps: 9146.23    TX-pps: 4465932

With the pktgen patches (2.6.31-rc5):

  tx_pkt_sz: 64   TX-Mbps: 5763.64        TX-pps: 11257313
  tx_pkt_sz: 128  TX-Mbps: 8414.91        TX-pps: 8217709
  tx_pkt_sz: 256  TX-Mbps: 9141.70        TX-pps: 4463720


Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
