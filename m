From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: igmp snooping?
Date: Thu, 19 May 2005 00:14:02 +0200
Message-ID: <20050518221401.GA11148@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Is someone working on igmp snooping (and/or active discovery) for
bridging yet?  I currently have a need for this, so if noone is
working on it yet, I'll probably give it a go myself.

AFAICS, for the kernel part:
- Add capability to add/modify/delete multicast (ethernet) addresses
  in the forwarding database.  Each multicast fdb entry contains a port
  bitmask of ports that are interested in this address.
- Lookup multicast addresses in the forwarding path, instead of flooding
  every packet.
- Policy decision on whether to drop or flood traffic for multicast
  addresses that have no corresponding fdb entry.
- Add capability for userland to 'steal' IGMP packets.  (I.e. to be able
  to prevent them from being forwarded.)

And some userspace daemon that implements the necessary bits.

Ideas?


cheers,
Lennert
