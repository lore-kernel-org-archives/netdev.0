From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ip neigh output are incomplete, 3.4.1
Date: Thu, 07 Jun 2012 16:22:15 +0200
Message-ID: <1339078935.5083.13.camel@edumazet-glaptop>
References: <ea0a16e085389e68b480c4b0baf05645@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:60353 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760447Ab2FGOWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 10:22:21 -0400
Received: by eeit10 with SMTP id t10so255924eei.19
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2012 07:22:20 -0700 (PDT)
In-Reply-To: <ea0a16e085389e68b480c4b0baf05645@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-07 at 16:09 +0300, Denys Fedoryshchenko wrote:
> I have a host with large L2 network (around 100 L2TP tunnels bridged to 
> one interface). 3.4.1 kernel, x86, 32bit.
> 
> ip route add 172.16.0.0/16 dev br0
> 
> GlobalNAT ~ # cat /proc/net/arp |wc -l
> 2
> GlobalNAT ~ # cat /proc/net/arp |wc -l
> 3575
> GlobalNAT ~ # cat /proc/net/arp |wc -l
> 4613
> GlobalNAT ~ # cat /proc/net/arp |wc -l
> 5117
> 
> And at same time
> GlobalNAT /config # ip neigh |wc -l
> 52

Thansk for the report, I am testing a fix and send patch ASAP.
