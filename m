From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 not advertising 1000mbit after suspend anymore
Date: Wed, 22 Jul 2009 00:37:41 +0200
Message-ID: <20090721223741.GA24735@electric-eye.fr.zoreil.com>
References: <20090719190937.7393ea99@pluto-lenny.milky.way>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Benjamin S." <sbenni@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:44445 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753974AbZGUXWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 19:22:40 -0400
Received: from electric-eye.fr.zoreil.com (localhost.localdomain [127.0.0.1])
	by electric-eye.fr.zoreil.com (8.14.2/8.14.1) with ESMTP id n6LNPuhq026121
	for <netdev@vger.kernel.org>; Wed, 22 Jul 2009 01:25:56 +0200
Content-Disposition: inline
In-Reply-To: <20090719190937.7393ea99@pluto-lenny.milky.way>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin S. <sbenni@gmx.de> :
[...]
> I have a Gigabyte GA-MA78G-DS3H mainboard with a RTL8111/8168B Realtek 
> Gigabit Ethernet Controller. Until first suspend everything works as 
> expected, but after suspend only 100mbit are used instead of 1000.

Which kernel do you use ?

[...]
> mii-tool after suspend:
> eth0: negotiated 100baseTx-FD flow-control, link ok
>   product info: vendor 00:07:32, model 17 rev 2
>   basic mode:   autonegotiation enabled
>   basic status: autonegotiation complete, link ok
>   capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
>   advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control
>   link partner: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control
> 
> mii-tool after setting speed to 1000 with "ethtool -s eth0 speed 1000":
> eth0: negotiated 1000baseT-FD flow-control, link ok
[snip]

At which point it works correctly again, right ?

[...]
> I did not knew if the Switch could be the problem and thus I connected the 
> card to my laptop which also has a gigabit controller, but the result was 
> the same as above.

At least some 8168 appear to lose the link settings :o/

Please send the XID line of the offender taken from dmesg.

-- 
Ueimor
