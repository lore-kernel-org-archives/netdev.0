From: Ben Greear <greearb@candelatech.com>
Subject: new networking features
Date: Thu, 08 May 2003 10:48:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EBA9852.4030808@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have a little collection of networking features that may be of
interest.  My patches are against 2.4.20...  If anyone thinks any of
these are of interest, I will break them out and send them to the list
for review/inclusion...

1)  send-to-self:  Add an IOCTL that allows an interface to be configured
     so that it will answer arps from other interfaces on the same machine.
     Also tweaks ip-v4 a bit.
     Allows:  can send traffic from one interface to another interface on same machine
      over an external network.  Tested with ipv4, may automatically work with ipv6
      too.

2)  802.1Q VLAN:  Add an ioctl that can be used to verify that a device is indeed
     an 802.1Q VLAN device (no more relying on name or luck).

3)  MAC-VLANs:  (Upgraded patch that someone else sent me.)  Allows one to specify
     VLAN-like devices based on source or destination MAC addresses (no extra padding
     in the ethernet frame.)
     This requires a hook in the skb-rx logic, near where the bridging logic has it's
     hook.

4)  Pktgen updates:  Allows receiving (and accounting) packets & threading changes.  Also requires
     a hook in the skb-rx logic.  (Dave already said he didn't like it before, and I
     assume he still doesn't, but including it here for completeness).


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
