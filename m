From: Andreas Jellinghaus <aj@dungeon.inka.de>
Subject: ipsec without interface
Date: 29 May 2003 21:16:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1054235787.605.21.camel@simulacron>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

sure, the simple configurations work fine with kernel 2.5.* ipsec.
But I miss the interface and things I did with it. How are these
setups supposed to work without an interface?

a) in iptables allow everything coming from ipsec0,
   allow only ssh and ipsec on eth0.

b) source address selection. put the default route on ipsec0,
but the route to the tunnel endpoint on eth0 with the right gateway.

also I wonder why I see incoming packets before and after encryption,
but outgoing packets only before encryption.

Andreas
