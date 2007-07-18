From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek RTL8111B serious performance issues
Date: Wed, 18 Jul 2007 23:50:56 +0200
Message-ID: <20070718215056.GC9755@electric-eye.fr.zoreil.com>
References: <Pine.SOC.4.64.0707172328150.3299@katana> <20070718072635.GA26243@electric-eye.fr.zoreil.com> <Pine.SOC.4.64.0707181516300.19789@katana>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: john@BlueSkyTours.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:55225 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761941AbXGRVxV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2007 17:53:21 -0400
Content-Disposition: inline
In-Reply-To: <Pine.SOC.4.64.0707181516300.19789@katana>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

john@BlueSkyTours.com <john@BlueSkyTours.com> :
[...]
> Unfortunately, the 20070628 patch did not make any difference.

@!#$

[...]
> >http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.22-rc6/r8169-20070628/
> 
> I tried various patches from that directory (aren't most or all of them
> included in the 20070628 patch?), but none of them helped either.

The patches from the directory should be applied on top of each other.
When they are all applied, you get the 20070628 patch. You are not supposed
to apply them in random order (there is some margin of course).

[...]
> This problem could be very difficult to track down.  Like I said, it
> definately effects emacs and firefox being "drawn" on a remote computer.
> Ping times, however, are not that bad:
> 
> PING 192.168.26.150: 56 data bytes
> 64 bytes from dyn26-1.blueskytours.com (192.168.26.150): icmp_seq=0. 
> time=0.287 ms
[...]
> 64 bytes from dyn26-1.blueskytours.com (192.168.26.150): icmp_seq=6. 
> time=0.150 ms

It looks quite fine.

> Also, wget gets good throughput when retrieving files.
> 
> It just seems to be X traffic which is extremely slow.  Using the old
> Linksys 10/100 PCI NIC, emacs comes up virtually instantaneously.  Using the
> integrated Realtek 8111B, emacs takes 10 seconds to draw.

Can you take a tethereal -w log.pcap for both cards with the command
'ping -c 4 $someplace && emacs' and publish the log.pcap files ?

-- 
Ueimor
