From: John Sigler <linux.kernel@free.fr>
Subject: Re: neigh: timer & !nud_in_timer
Date: Thu, 03 Jan 2008 10:23:03 +0100
Message-ID: <477CA977.2090804@free.fr>
References: <476A6F85.7070905@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-rt-users@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g19.free.fr ([212.27.42.30]:47103 "EHLO smtp4-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752893AbYACJXF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2008 04:23:05 -0500
In-Reply-To: <476A6F85.7070905@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Sigler wrote:

> I noticed the following message in my kernel log.
> kernel: neigh: timer & !nud_in_timer
> (Might be due to a race condition.)
> 
> I'm running a UP Linux version 2.6.22.1-rt9
> ( http://rt.wiki.kernel.org/index.php )
> 
> The following /proc entries might be relevant.
> 
> /proc/sys/net/ipv4/conf/all/arp_accept
> 0
> /proc/sys/net/ipv4/conf/all/arp_announce
> 2
> /proc/sys/net/ipv4/conf/all/arp_filter
> 0
> /proc/sys/net/ipv4/conf/all/arp_ignore
> 1
> 
> I also lowered the priority of softirq-timer/0 to 10 which means
> it can be interrupted by other IRQ handlers.

Comments or musings?
