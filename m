From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bridge: reset IPCB in br_parse_ip_options
Date: Wed, 13 Apr 2011 08:24:57 -0700
Message-ID: <20110413082457.52784d6d@nehalam>
References: <4DA3F909.5020609@scotdoyle.com>
	<1302608951.3233.33.camel@edumazet-laptop>
	<1302613353.30934.22.camel@polaris.local>
	<1302614145.3233.47.camel@edumazet-laptop>
	<1302617968.30934.34.camel@polaris.local>
	<1302619749.3233.56.camel@edumazet-laptop>
	<1302621233.30934.44.camel@polaris.local>
	<1302624851.3233.63.camel@edumazet-laptop>
	<20110412092039.69f420f6@nehalam>
	<1302626152.3233.66.camel@edumazet-laptop>
	<20110412164557.GF2047@stratus.com>
	<1302627281.3233.70.camel@edumazet-laptop>
	<1302628720.3233.84.camel@edumazet-laptop>
	<4DA4E68B.9010401@scotdoyle.com>
	<4DA522B2.90200@scotdoyle.com>
	<4DA5BCF7.9020606@scotdoyle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	netdev@vger.kernel.org
To: Scot Doyle <lkml@scotdoyle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33017 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753247Ab1DMPZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 11:25:00 -0400
In-Reply-To: <4DA5BCF7.9020606@scotdoyle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> The net effect is that three patches are required to eliminate the panics.
> 
> These two patches have been accepted by David:
> http://article.gmane.org/gmane.linux.network/192015
> http://article.gmane.org/gmane.linux.network/192055
> 
> This patch, incrementally authored by Stephen and Eric and compiled by 
> me, is also required:
> http://article.gmane.org/gmane.linux.network/192007
> 
> What should happen for this third patch to be included upstream?

Although making IP more robust is a good.
I still think bridging shouldn't give bad packets to IP.
