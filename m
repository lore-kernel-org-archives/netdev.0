From: Ben Greear <greearb@candelatech.com>
Subject: Interesting machine lockup with 8139too driver.
Date: Sat, 12 Apr 2003 13:33:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E987801.2080107@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I was beating my machine with 8139 NICs (and a slow CPU and only 128MB
RAM) by running a lot of UDP and TCP connections through it...  I usually
set my socket buffers quite large, so they may be consuming too much of
the vital kernel RAM.

After a while, I saw this repeated over and over on the console:

eth[01]:  Memory squeeze, dropping packet.


Now, that is the only thing I can see on this machine.  I cannot
get a bash prompt and changing virtual terminals does not work.

I did not see the OOM handler kick in, though it's possible it
scrolled off the screen.  At the least, it may be worthwhile to
throttle the squeeze messages...

As a caveat:  I'm running some of my own hacked up networking
code, and it's possible its leaking memory or doing something else
bad.  I have not seen this problem on my other machine with different
NIC (and faster CPU and more RAM), though.

Take it easy,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
