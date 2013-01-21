From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill device
 specific ndisc information
Date: Mon, 21 Jan 2013 07:37:28 +0100
Message-ID: <50FCE228.3090801@gmail.com>
References: <50FC2EE4.3080705@gmail.com> <50FC3BB1.4070005@linux-ipv6.org>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:51911 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792Ab3AUGhc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 01:37:32 -0500
Received: by mail-ee0-f51.google.com with SMTP id d17so2620451eek.10
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2013 22:37:30 -0800 (PST)
In-Reply-To: <50FC3BB1.4070005@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> [ARP and NDISC]
> - both can be handled in more natural way.
> -- You will not need to mangle those packets when
>     sending/receiving.

This is also true if we introduce a function pointer. My last 
implementation does not mangle packets in the driver.

> -- You do not need to inspect ARP/NDISC packet.
>     By using netevent notification mechanism, you can
>     learn peer parameters.

That is worth to investigate. Will I get notifications when a ARP/NDISC 
will be send or only if the stack received ARP/NDISC packets? However, I 
can't see how this will help to get the firewire specific information 
into the ARP/NDISC packet. This has to be done either via the suggested 
function pointer or your extension of the mac address.
