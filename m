From: Ben Greear <greearb@candelatech.com>
Subject: reserving skbuffs for the drivers
Date: Sun, 20 Oct 2002 14:03:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB31A32.9020107@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm getting dropped rx packets because the network
driver cannot allocate an skbuf in time, evidently....

I have 256MB of RAM, is there some way to increase the amount of RAM
that the kernel keeps around for GFP_ATOMIC allocations?

Documentation I find talks about buffermem and freepages, which looks
hopeful, but they appear to no longer be in the proc file system as
tunables???

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
