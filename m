From: "Patrick R. McManus" <mcmanus@ducksong.com>
Subject: Intel 1000 MT slow to restart
Date: Wed, 26 Mar 2003 17:31:42 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030326223142.GA2032@ducksong.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm running intel's e1000 driver (versions 4.4.12 and tried 4.6.11)
for a 1000/MT (dual) nic on a 2.4.19 kernel.

for normal operations, everything is fine.. however if I do a 
"ifconfig eth0 down; ifconfig eth0 up" 20 or 30 seconds passes where I
can't do any traffic. the ifconfig up comes back quickly, and ifconfig
reports the driver as up (and netlink thinks its up if I try and add
another one).. I just can't move any traffic. no rx's and my tx's only
move counters in the driver - they don't actually make it to the
wire. 

if I do "ifconfig eth0 down; sleep 30; ifconfig eth0 up" all is well
immediately after the up.. The driver doesn't seem to be doing
anything different in either case - its as if the NIC itself is
enforcing some kind of quiet period. 

I'm really writing to see if I'm crazy and hoping someone else can
corroborate this is what they've seen too.

help?

-Patrick
