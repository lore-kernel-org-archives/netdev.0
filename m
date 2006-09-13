From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.18-rc6 memory mapped pcap truncates outgoing TCP packets,
 but not icmp
Date: Wed, 13 Sep 2006 20:44:21 +0200
Message-ID: <45085185.2060904@trash.net>
References: <20060913112307.GA1374@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: cpw@lanl.gov, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:9717 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S1751096AbWIMSoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 14:44:24 -0400
To: bert hubert <bert.hubert@netherlabs.nl>
In-Reply-To: <20060913112307.GA1374@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bert hubert wrote:
> Hi people,
> 
> I like to use memory mapped pcap (PACKET_MMAP) since off the shelf, linux is
> a tad prone to drop packets while capturing these days. It used to be lots
> better at it, but right now memory mapped pcap is the only way to get things
> working a bit. I've noticed this on many machines.
> 
> However, memory mapped pcap has started to truncate outgoing packets for me
> recently, and interestingly, I only see this with locally generated TCP
> packets, not with locally generated ICMP packets. I haven't yet tried UDP,
> nor actual sniffing, this is all locally generated packets going out on
> eth0.

Are you using TSO on the outgoing device? If so please try to log the
packet using iptables to see if it really is a TSO packet.

