From: Ben Greear <greearb@candelatech.com>
Subject: tg3 and machine lockup?
Date: Tue, 15 Jul 2003 22:07:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F14DD9C.9090807@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I was running 2500 pps tx+rx on a 100bt port, with a tg3 in
the same machine. 1000 tcp connections, memory pressure, and
cpu was max'ed out.

I plugged in the tg3 to a e1000 (via cross-over cable), and then, or
very soon after that, the machine hung solid (or, maybe it tried
to spew to console..was on kvm and not selected..)

Last thing I see in the /var/log/messages is tg3 saying flow control
is on for tx and rx.

Now, it could be one of a million things...but just curious if anyone
else has seen anything like this.  Kernel is 2.4.20 + my hacks.

Take it easy,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
