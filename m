From: Phil Oester <kernel@linuxace.com>
Subject: Re: [PATCH net-next-2.6] bonding: fix user-controlled queuing issues
Date: Tue, 22 Feb 2011 08:48:36 -0800
Message-ID: <20110222164836.GA15040@linuxace.com>
References: <1298328783-10073-1-git-send-email-andy@greyhouse.net>
 <20110222155518.GA14991@linuxace.com>
 <20110222161941.GE11864@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:53504 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754509Ab1BVQsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 11:48:41 -0500
Received: by gyh20 with SMTP id 20so423938gyh.19
        for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 08:48:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20110222161941.GE11864@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 22, 2011 at 11:19:41AM -0500, Andy Gospodarek wrote:
> Phil,
> 
> Can you send me the minimal set of tc rules that selects output queue 16
> and the output of /proc/net/bonding/bond0?
> 
> Private email is fine if you do not want to post it to the list.
> 
> Thanks,
> 
> -andy

I have no tc rules which select output queue 16 (I have no tc rules at all
in fact). 

Output of /proc/net/bonding/bond0 below.  The bond consists of two Intel
igb nics, which only have 8 queues.  Note, however, that eth0 is an ixgbe,
which has 16 queues:

ixgbe 0000:0b:00.0: Multiqueue Enabled: Rx Queue count = 16, Tx Queue count = 16

which may answer your question as to what is selecting queue 16.  

Phil 


Ethernet Channel Bonding Driver: v3.7.0 (June 2, 2010)

Bonding Mode: IEEE 802.3ad Dynamic link aggregation
Transmit Hash Policy: layer2+3 (2)
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

802.3ad info
LACP rate: slow
Aggregator selection policy (ad_select): stable
Active Aggregator Info:
        Aggregator ID: 1
        Number of ports: 2
        Actor Key: 17
        Partner Key: 6
        Partner Mac Address: 00:d0:05:xx:xx:xx

Slave Interface: eth1
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 00:1b:21:xx:xx:xx
Aggregator ID: 1

Slave Interface: eth2
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 00:1b:21:xx:xx:xx
Aggregator ID: 1
