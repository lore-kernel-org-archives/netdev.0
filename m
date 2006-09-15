From: bert hubert <bert.hubert@netherlabs.nl>
Subject: Re: 2.6.18-rc6 memory mapped pcap truncates outgoing TCP packets,   but not icmp
Date: Fri, 15 Sep 2006 14:02:35 +0200
Message-ID: <20060915120235.GA9833@outpost.ds9a.nl>
References: <20060913112307.GA1374@outpost.ds9a.nl> <45085185.2060904@trash.net> <20060914085618.GA4623@outpost.ds9a.nl> <450928B2.4090003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cpw@lanl.gov, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([213.244.168.210]:1757 "EHLO outpost.ds9a.nl")
	by vger.kernel.org with ESMTP id S1751305AbWIOMCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2006 08:02:37 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <450928B2.4090003@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> It appears to be intentionally, but I don't see a reason for it.
> Can you try if this patch makes it work as expected?

> [PACKET]: Don't truncate non-linear skbs with mmaped IO
> 
> Non-linear skbs are truncated to their linear part with mmaped IO.
> Fix by using skb_copy_bits instead of memcpy.

Works very well for me! I hope this can make it into 2.6.18.
Thanks everybody.



-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
