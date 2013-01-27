From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill device
 specific ndisc information
Date: Mon, 28 Jan 2013 04:28:47 +0900
Message-ID: <51057FEF.9090006@linux-ipv6.org>
References: <50FC2EE4.3080705@gmail.com> <50FC3BB1.4070005@linux-ipv6.org> <50FC6068.3020302@gmail.com> <50FCA825.7070609@linux-ipv6.org> <50FCDF5D.3060300@gmail.com> <20130121083957.6e2c5a68@stein> <50FD962B.8020500@gmail.com> <50FD9DB7.60802@linux-ipv6.org> <50FDB039.2070604@gmail.com> <20130127154332.6b5730f9@stein> <5105621F.4040408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
	netdev <netdev@vger.kernel.org>,
	linux1394-devel@lists.sourceforge.net,
	David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:37139 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754616Ab3A0T2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 14:28:48 -0500
In-Reply-To: <5105621F.4040408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephan Gatzka wrote:

>> I am not a contributor to net/, hence don't have a say over how the
>> networking APIs should evolve.
>>
>> Any solution is fine with me, as long as net/ does not use any definitions
>> or declarations from <linux/firewire.h>.
> 
> O.k. then I will go for Yoshifujis "extended hwaddress" approch.
> 
> I think I will divide all the stuff into two major pieces:
> 
> First I will rewrite the existing IPv4 over Firewire driver to use the notification mechanisms and also generate the RFC2734 ARP packets in the arp code.
> 
> Then I'll implement the IPv6 stuff based on that IPv4 solution.

I even think that we do not need to have event notification if we
can just use max_rec, sspd and fifo embedded in the destination
"MAC address" in the sending packet.

--yosshfuji
