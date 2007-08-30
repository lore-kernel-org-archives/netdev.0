From: Meelis Roos <mroos@linux.ee>
Subject: Re: ipv4_get_l4proto: Frag of proto 17
Date: Thu, 30 Aug 2007 16:04:00 +0300 (EEST)
Message-ID: <Pine.SOC.4.64.0708301557400.9520@math.ut.ee>
References: <Pine.SOC.4.64.0708211355310.24028@math.ut.ee> <46D66D00.7060801@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:35415 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751496AbXH3NED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2007 09:04:03 -0400
In-Reply-To: <46D66D00.7060801@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Yesterdays git snapsot on a normal home PC spams dmesg with the following
> > line:
> > ipv4_get_l4proto: Frag of proto 17
> 
> In what situation does this happen?

It happens some times every hour on the average. Seems to be some UDP 
traffic. Firewall allows in any UDP that is ESTABLISHEFD,RELATED, DHCP 
(some more UDP rules with counter 0 so not important). Additionally 
there is internal netowkr that sometimes has a laptop but usually not 
and the messages have appeared also when there is nothin in the internal 
network.

Locally mldonkey is probably using UDP, and lsof -i | grep UDP tells 
that named, avahi-daemon, dhcpd, chronyd, nmbd and cupsd are listening 
on UDP sockets (most of them on internal network).

But I have no idea what application is causing the messages.

-- 
Meelis Roos (mroos@linux.ee)
