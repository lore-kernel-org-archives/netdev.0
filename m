From: Ben Greear <greearb@candelatech.com>
Subject: Re: tulip NAPI patch that works with 2.4.20-pre9 or so?
Date: Sun, 20 Oct 2002 22:45:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB3948E.6080907@candelatech.com>
References: <3DB1D6B5.6080305@candelatech.com> <15795.2902.180818.661384@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Ben Greear writes:
>  > The latest NAPI tulip patch I could find (tulip-020922.pat)
>  > will not load.  The problem appears that the tulip_misc.c file
>  > no longer exists...
> 
>  :-( I'll look into it.

It works if you fix up the Makefile to not compile tulip_misc.c
and if you change tulip.h to not define EXTRA_STATS.

I'm running it now...initial 5 minutes are a definate improvement
over the in-kernel code....now, if it will only remain stable :)

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
