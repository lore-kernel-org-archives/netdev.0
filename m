From: Ben Greear <greearb@candelatech.com>
Subject: Re: Linux router performance (3c59x) (fwd)
Date: Mon, 17 Mar 2003 20:48:08 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E76A508.30007@candelatech.com>
References: <Pine.LNX.4.51.0303172239390.30872@ns.istop.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ralph+d@istop.com
In-Reply-To: <Pine.LNX.4.51.0303172239390.30872@ns.istop.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ralph Doncaster wrote:
> I haven't heard from Jamal or Dave, so perhaps someone from this list has
> some wisdom to impart.
> Currently the box in question is running a 67% system load with ~40kpps.
> Here's the switch port stats that the 2 3c905cx cards are plugged into:
> 
>   5 minute input rate 36143000 bits/sec, 8914 packets/sec
>   5 minute output rate 54338000 bits/sec, 10722 packets/sec
> -
>   5 minute input rate 50585000 bits/sec, 12445 packets/sec
>   5 minute output rate 34326000 bits/sec, 9596 packets/sec

When using larger packets, NAPI doesn't have much effect.

Have you tried routing with simple routing tables to see if that
speeds anything up?

Could also try an e100 or Tulip NIC.  Those usually work pretty
good...  Or, could use an e1000 GigE NIC...

It's also possible that you are just reaching the limit of your
system.

Ben


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
