From: Ben Greear <greearb@candelatech.com>
Subject: problems achieving decent throughput with latency.
Date: Sat, 01 Feb 2003 14:13:01 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E3C466D.7030602@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am testing my latency-insertion tool, and I notice that tcp will not use
all of the available bandwidth if there is any significant amount of latency
on the wire.

For example, with 25ms latency in both directions, I see about 8Mbps
bi-directional throughput.

If I lower that to 15ms, I see 12Mbps bi-directional throughput.

I see 27Mbps at 5ms.

Here is the /proc/net/tcp output at 5ms latency.

machine demo2
   13: 050302AC:80EB 070302AC:80EB 01 0005900C:0002012E 01:00000016 00000000     0        0 578943 3 c6628a80 22 4 1 45 -1

machine demo1
   11: 070302AC:80EB 050302AC:80EB 01 00010DDB:00000000 01:00000014 00000000     0        0 513094 3 c62c5080 21 4 1 45 -1


Any ideas why it is so slow at the higher latencies?  Any other info
I can gather to help determine the cause?

(UDP does not experience this slowdown, so I believe my latency
insertion tool is working as designed, but it's always possible it is
to blame...)


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
