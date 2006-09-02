From: jamal <hadi@cyberus.ca>
Subject: Re: [IPSEC]: searching  SAD without assumming L3 details
Date: Sat, 02 Sep 2006 14:11:12 -0400
Message-ID: <1157220673.5077.22.camel@jzny2>
References: <1157204582.5197.4.camel@jzny2>
	 <Pine.LNX.4.64.0609021102570.4222@d.namei> <1157217413.5077.17.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:41122 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1750758AbWIBSLR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Sep 2006 14:11:17 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GJZxg-0001tX-SK
	for netdev@vger.kernel.org; Sat, 02 Sep 2006 14:11:20 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <1157217413.5077.17.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-02-09 at 13:16 -0400, jamal wrote:

> the call is made at the moment only by pktgen (kernel threads on
> dev_queue_xmit level contending with softirqs essentially). I think
> (although havent tried) the spin_{un}lock_bh() wont work. Thoughts?
> Obviously the easy thing for me to do is change it and see what
> happens;->

Both your suggestions work. Should i instead just use read_{un}lock_bh?
All i am doing is scanning to find the state.

cheers,
jamal



-- 
VGER BF report: U 0.502731
