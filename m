From: Andrew Clayton <andrew@digital-domain.net>
Subject: Re: Networking blowing up in 3.17-rc
Date: Thu, 25 Sep 2014 20:02:26 +0100
Message-ID: <20140925200226.0f47c112@omega.digital-domain.net>
References: <20140925182556.610073d2@omega.digital-domain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu.digital-domain.net ([108.61.197.113]:39737 "EHLO
	mu.digital-domain.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbaIYTC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 15:02:29 -0400
Received: from omega.digital-domain.net (tau.digital-domain.net [217.169.2.54])
	(authenticated bits=0)
	by mu.digital-domain.net (8.14.7/8.14.7) with ESMTP id s8PJ2Qk0010812
	(version=TLSv1/SSLv3 cipher=AES128-GCM-SHA256 bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 20:02:27 +0100
In-Reply-To: <20140925182556.610073d2@omega.digital-domain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Sep 2014 18:25:56 +0100, Andrew Clayton wrote:

> Kernel is 3.17.0-rc6-00180-g452b6361c4d9
> 
> System is Fedora 20 64bit on an Intel Quad core Q9400 with 4GB RAM.

Typically this isn't reproducible. I rebooted into the latest F20
kernel 3.16.3-200.fc20.x86_64 and hit that URL in Firefox, then only I
noticed was the first time I loaded the URL was that the mem field of
the TCP line in /proc/net/sockstat spiked up to a little over 5000
before coming back down. But no noticeable ill effects.

I rebooted back into 3.17.0-rc6-00180-g452b6361c4d9, but this time
Firefox loaded the URL without issue. Rebooted back and forth a couple
of time but couldn't hit the problem, maybe there's some other factor
involved. I've too the opportunity to build the latest kernel
3.17.0-rc6-00247-g005f800508eb. I'll see if I can hit the problem again
after the machine has been up a while.

Cheers,
Andrew
