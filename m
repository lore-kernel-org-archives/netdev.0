From: Ben Greear <greearb@candelatech.com>
Subject: pktgen and timers in 2.6
Date: Tue, 24 Feb 2004 10:35:45 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <403B9981.5050103@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


The pktgen module often wants to sleep for a very short
amount of time (1ms, maybe even .01 ms) between sending packets....

Currently, it busy-spins to achieve this delay.

Would the real-time timers in 2.6 allow us to run
pktgen off of timers instead so that we do not need to
sleep or spin?

I have looked around, but I have not been able to find any
docs on the new real-time timer features.  Is there any
documentation for how to use this in kernel modules?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
