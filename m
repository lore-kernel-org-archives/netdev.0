From: Ben Greear <greearb@candelatech.com>
Subject: Re: tulip NAPI patch that works with 2.4.20-pre9 or so?
Date: Sun, 20 Oct 2002 15:44:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB331DF.9090401@candelatech.com>
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
> 
> 
>  > If anyone has a newer patch, I'd love to try it out.
>  
> Try Jamal's drop-in-replacement
> http://www.cyberus.ca/~hadi/patches/tulip-napi.tgz

This one froze up after a few seconds on a p430 Phobos 4-port NIC.
(60Mbps on one port, 10Mbps on the others)

However, becker's driver hangs as well, and the 4x5 driver doesn't
even get started...

The driver in 2.4.20-pre9 works pretty good...but I seem to get
rx lockups from time to time...  Still trying to figure out how
to work around that problem...

I'll donate a NIC to a driver hacker if they think that will help
them fix the problem.

Thanks,
Ben

> 
> Cheers.
> 						--ro
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
