From: Ben Greear <greearb@candelatech.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 11:21:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EE621BE.6070900@candelatech.com>
References: <008001c32eda$56760830$4a00000a@badass> <20030609195652.E35696@shell.cyberus.ca> <Pine.LNX.4.51.0306092006420.12038@ns.istop.com> <20030609204257.L35799@shell.cyberus.ca> <Pine.LNX.4.51.0306092200150.28167@ns.istop.com> <3EE54F4D.50909@candelatech.com> <Pine.LNX.4.51.0306101402350.16454@ns.istop.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: ralph+d@istop.com
In-Reply-To: <Pine.LNX.4.51.0306101402350.16454@ns.istop.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ralph Doncaster wrote:
> On Mon, 9 Jun 2003, Ben Greear wrote:
> 
> 
>>One waring about e1000's, make sure you have active airflow across the NICs
>>if you put two together.  Otherwise, buy a dual port NIC...it has a single
>>chip and you will have less cooling issues.
> 
> 
> I just took a closer look at my e1000's.  They've got a small RC82540EM
> bga chip on them, manufactured 25th week of '02. If these things do get
> hot enough to cause problems why wouldn't Intel have them manufactured
> with heatsinks attached?

Dunno...  I wish they had.  My machine had fairly bad cooling (2U, open case). However, when
I put a fan on them, no reboots, whereas before I could crash the machine
with nasty memory corruption after about 1 hour of sustained > 100Mbps
bi-directional traffic.

The temp probe I used showed them to be at about their operating
max, though I forget what that was now...

Maybe your chipset or cooling is better and you won't hit it..but if you do
see crashes, try a fan :)

Ben

> 
> -Ralph
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
