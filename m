From: Ben Greear <greearb@candelatech.com>
Subject: Re: How to enable more than ~256 routing tables?
Date: Tue, 22 Apr 2003 00:45:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EA4F323.7010805@candelatech.com>
References: <3EA4EAFD.5020808@candelatech.com> <20030422.161645.80924947.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20030422.161645.80924947.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / ???? wrote:
> In article <3EA4EAFD.5020808@candelatech.com> (at Tue, 22 Apr 2003 00:10:53 -0700), Ben Greear <greearb@candelatech.com> says:
> 
> 
>>Is it possible to just change the RT_TABLE_MAX to be higher and have 256-????
>>be more /* User defined values */ ?
> 
> 
> No. rtm_table in rtmsg{} is unsigned char.

Thanks for the response...but I was definately hoping for some better
news!

I'm guesing that to change this would mean at least a recompile of
the user-space 'ip' utility, (and who knows what else!)

Why o why did someone think that 256 was all anyone would ever want!

Think we could at least increase this to 16 bits for 2.5?

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
