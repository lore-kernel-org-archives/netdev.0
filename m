From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: WARNING: at net/ipv4/af_inet.c:155	inet_sock_destruct+0x122/0x13a()
Date: Thu, 13 Aug 2009 13:04:15 -0400
Message-ID: <4A84478F.5010808@hp.com>
References: <4A76A009.40605@wpkg.org>	<1249346282.6479.5.camel@merlyn>	 <20090803.212007.253928711.davem@davemloft.net>	 <4A77D2BA.3040304@gmail.com>  <4A831F69.1080703@hp.com> <1250176905.7289.7.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, mangoo@wpkg.org,
	netdev@vger.kernel.org
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:33923 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755028AbZHMREQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 13:04:16 -0400
In-Reply-To: <1250176905.7289.7.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Dykstra wrote:
> On Wed, 2009-08-12 at 16:00 -0400, Vlad Yasevich wrote:
>> BTW, I've seen the same issue in 2.6.28 and 2.6.29 while doing a bunch
>> of NFS-over-UDP testing.  I've seen the issue reported in 2.6.27 as well,
>> but it went by ignored.  It's not easy to reproduce as it seems like it
>> requires quite a bit traffic over over multiple interfaces.
> 
> I've been unable to reproduce it so far.  Has bonding always been
> present in the cases you've seen, or are multiple independent interfaces
> sufficient?

Bonding wasn't used in this case, ie. no bonding interfaces were configured.

> 
> In the case you reported initially, openvpn was using UDP, but the peer
> was dead, so there presumably wasn't much traffic from that app.  Was
> there lots of NFS-over-UDP traffic also going on?

The openvpn case wasn't mine.  I didn't use any vpn traffic.  Just 2
systems back-to-back with NFS traffic between them.

Yes, there was a lot of NFS over UDP traffic and not much other UDP traffic.

> 
> Where was the independent report on 2.6.27

http://article.gmane.org/gmane.linux.nfs/22887
http://kerneltrap.org/mailarchive/linux-netdev/2008/11/26/4244994

-vlad

> 
>   --  John
> 

