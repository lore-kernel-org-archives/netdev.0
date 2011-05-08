From: Alex Bligh <alex@alex.org.uk>
Subject: Re: Scalability of interface creation and deletion
Date: Sun, 08 May 2011 09:06:11 +0100
Message-ID: <8E10C0B83130C288FD7BA9B8@nimrod.local>
References: <891B02256A0667292521A4BF@Ximines.local>	
 <1304770926.2821.1157.camel@edumazet-laptop>	
 <0F4A638C2A523577CDBC295E@Ximines.local>	
 <1304785589.3207.5.camel@edumazet-laptop>	
 <178E8895FB84C07251538EF7@Ximines.local>	
 <1304793174.3207.22.camel@edumazet-laptop>	
 <1304793749.3207.26.camel@edumazet-laptop>
 <1304838742.3207.45.camel@edumazet-laptop>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Alex Bligh <alex@alex.org.uk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:57108 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751502Ab1EHIGO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2011 04:06:14 -0400
In-Reply-To: <1304838742.3207.45.camel@edumazet-laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric,

> By the way, if I change HZ from 1000 to 100 I now have ten times slower
> result :
>
># ip link add link eth0 eth0.103 type vlan id 103
># time ip link del eth0.103
>
> real	0m0.430s
> user	0m0.000s
> sys	0m0.000s
>
> So all this is related to your HZ value, even in a CONFIG_NO_HZ=y
> kernel.

That's very mysterious.

> Alex, I guess you have HZ=250 ?

I have HZ=100. I am basically using the Ubuntu default with
localmodconfig to make compile times sensible.

amb@nattytest:~$ cd kernel/linux-2.6/
amb@nattytest:~/kernel/linux-2.6$ fgrep HZ .config
CONFIG_RCU_FAST_NO_HZ=y
CONFIG_NO_HZ=y
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
# CONFIG_MACHZ_WDT is not set



-- 
Alex Bligh
