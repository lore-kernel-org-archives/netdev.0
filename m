From: jamal <hadi@cyberus.ca>
Subject: Re: pktgen patch available for perusal.
Date: Sat, 04 Nov 2006 07:32:12 -0500
Message-ID: <1162643532.5166.34.camel@jzny2>
References: <45468F2E.4060809@candelatech.com>
	 <17736.54766.657083.873206@robur.slu.se> <4548F166.1020001@candelatech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:53642 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S965359AbWKDMcT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Nov 2006 07:32:19 -0500
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GgKhB-0005ra-De
	for netdev@vger.kernel.org; Sat, 04 Nov 2006 07:32:21 -0500
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4548F166.1020001@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-01-11 at 11:11 -0800, Ben Greear wrote:

> I'd be thrilled to have the receive logic go into pktgen, even if 
> it was #if 0 with a comment
> showing how to patch dev.c to get it working.  It would make my 
> out-of-tree patch smaller
> and should help others who are doing research and driver development...
> 

I use pktgen extensively these days for ipsec testing. I also record
stats for pkts i receive using a tc action drop. Very simple and works
great.  
Ben, you keep insisting on doing this hook (every 3 months) because you
dont want to invest time to do it with netlink (I thought you sold this
as part of your product - the investment of your time is really not that
high). If you tell me what the packet trigger is, I will send you a
script ;->

Robert, I have started writing some generic netlink messaging to replace
the /proc that i will send your way. I need to get consensus on some
tunnel-mode IPSEC patches first then i will send the about three
patchsets your way (to replace the old ones i sent earlier).

cheers,
jamal

