From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH - RFC] [1/5] 64-bit network statistics - generic net
Date: Sat, 05 Jul 2003 14:41:00 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3F0745EC.1060204@candelatech.com>
References: <E19YtAq-0006Xf-00@calista.inka.de> <200307051637.52252.jeffpc@optonline.net> <3F0737D1.5090109@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Sipek <jeffpc@optonline.net>,
	Bernd Eckenfels <ecki@calista.eckenfels.6bone.ka-ip.net.sgi.com>,
	linux-kernel@vger.kernel.org, Andrew Morton <akpm@digeo.com>,
	Dave Jones <davej@codemonkey.org.uk>,
	Linus Torvalds <torvalds@osdl.org>, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F0737D1.5090109@pobox.com>
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> The net stats are already unsigned long internally.
> 
> 64-bit case is handled quite nicely today, thanks :)
> 
> I'm such a 64-bit bigot that "buy a 64-bit computer" is a solution I 
> commonly suggest, and it seems to fit well here, too.
> 
>     Jeff, wondering if Intel will bother to compete w/ Athlon64

Untill the net-stats are 64-bit on 32-bit systems, we will need some
way to know if they have wrapped or not when reading from nettool
and getting 64-bit numbers.

I guess what I really mean to say is that, if nettool is returning 64-bit
values, we need to know which ones are obtained from 32-bit counters.
32 -> 64 bit mapping will require wrap handling on low 32-bits, but
64 -> 64 bit mapping will require wrapping about 4-billion times less often :)

Perhaps a precision field is also needed for backwards/forwards compatability,
and perhaps a nettool version field as well to also help with backwards/forwards
compat.

Ben

> 
> 
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
