From: Ben Greear <greearb@candelatech.com>
Subject: Update on e1000 troubles (over-heating!)
Date: Sat, 05 Oct 2002 20:38:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D9FB053.4040001@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel <linux-kernel@vger.kernel.org>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I believe I have figured out why the e1000 crashed my machine
after .5 - 1 hours:  The NIC was over-heating.  I measured one of
the NICs after the machine crashed with an external (cheap) temp
probe.  It registered right at 50 degrees C, and this was about 15-30
seconds after it crashed.

The dual e1000 NIC I have seems to run much cooler, and has been
running at 430Mbps bi-directional on both ports for about 6 hours now
with no obvious problems.

So, I'm going to try to purchase some heat sinks and glue them onto
the e1000 server nics, to see if that fixes the problem.

Hope this proves useful to anyone experiencing similar strange
crashes!

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
