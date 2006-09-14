From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: 2.6.18-rc6 memory mapped pcap truncates outgoing TCP packets, but not icmp
Date: Thu, 14 Sep 2006 14:52:31 +0400
Message-ID: <20060914105231.GA24143@ms2.inr.ac.ru>
References: <20060913112307.GA1374@outpost.ds9a.nl> <45085185.2060904@trash.net> <20060914085618.GA4623@outpost.ds9a.nl> <450928B2.4090003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bert hubert <bert.hubert@netherlabs.nl>, cpw@lanl.gov,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:20369 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751153AbWINKx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 06:53:28 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <450928B2.4090003@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> [PACKET]: Don't truncate non-linear skbs with mmaped IO
> 
> Non-linear skbs are truncated to their linear part with mmaped IO.
> Fix by using skb_copy_bits instead of memcpy.

Ack.

I remember this trick. The "idea" was that I needed only TCP header in any
case and it was perfect cutoff. This hack was not supposed to survive. :-)

Alexey
