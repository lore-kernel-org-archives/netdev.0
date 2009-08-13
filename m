From: Tomasz Chmielewski <mangoo@wpkg.org>
Subject: Re: WARNING: at net/ipv4/af_inet.c:155	inet_sock_destruct+0x122/0x13a()
Date: Thu, 13 Aug 2009 20:16:59 +0200
Message-ID: <4A84589B.6020002@wpkg.org>
References: <4A76A009.40605@wpkg.org>	<1249346282.6479.5.camel@merlyn>	 <20090803.212007.253928711.davem@davemloft.net>	 <4A77D2BA.3040304@gmail.com>  <4A831F69.1080703@hp.com> <1250176905.7289.7.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.syneticon.net ([78.111.66.105]:41448 "EHLO
	mx03.syneticon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439AbZHMSRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 14:17:34 -0400
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
> 
> In the case you reported initially, openvpn was using UDP, but the peer
> was dead, so there presumably wasn't much traffic from that app.  Was
> there lots of NFS-over-UDP traffic also going on?

There was quite a bit of NFS, but over TCP.

The other type of traffic was iSCSI (made with tgt as a target).


-- 
Tomasz Chmielewski
http://wpkg.org
