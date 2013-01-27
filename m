From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill device
 specific ndisc information
Date: Sun, 27 Jan 2013 18:21:35 +0100
Message-ID: <5105621F.4040408@gmail.com>
References: <50FC2EE4.3080705@gmail.com> <50FC3BB1.4070005@linux-ipv6.org> <50FC6068.3020302@gmail.com> <50FCA825.7070609@linux-ipv6.org> <50FCDF5D.3060300@gmail.com> <20130121083957.6e2c5a68@stein> <50FD962B.8020500@gmail.com> <50FD9DB7.60802@linux-ipv6.org> <50FDB039.2070604@gmail.com> <20130127154332.6b5730f9@stein>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev <netdev@vger.kernel.org>,
	linux1394-devel@lists.sourceforge.net,
	David Miller <davem@davemloft.net>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f41.google.com ([209.85.214.41]:35813 "EHLO
	mail-bk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753912Ab3A0RVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 12:21:40 -0500
Received: by mail-bk0-f41.google.com with SMTP id q16so819335bkw.0
        for <netdev@vger.kernel.org>; Sun, 27 Jan 2013 09:21:38 -0800 (PST)
In-Reply-To: <20130127154332.6b5730f9@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>
> I am not a contributor to net/, hence don't have a say over how the
> networking APIs should evolve.
>
> Any solution is fine with me, as long as net/ does not use any definitions
> or declarations from <linux/firewire.h>.

O.k. then I will go for Yoshifujis "extended hwaddress" approch.

I think I will divide all the stuff into two major pieces:

First I will rewrite the existing IPv4 over Firewire driver to use the 
notification mechanisms and also generate the RFC2734 ARP packets in the 
arp code.

Then I'll implement the IPv6 stuff based on that IPv4 solution.

Regards and many thanks for the discussion especially to Yoshifuji.

Stephan
