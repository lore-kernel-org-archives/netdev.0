From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: arp(8) can create entry with with a broadcast/multicast MAC address
Date: Sat, 12 Jun 2004 14:51:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040612125149.GA23367@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(please CC on replies.)

Hi,

Just saw this:

# /sbin/arp -s -i eth0 1.2.3.4 ff:ff:ff:ff:ff:ff
# /sbin/arp -n | grep 1.2.3.4
1.2.3.4                  ether   FF:FF:FF:FF:FF:FF   CM                    eth0
# 

Why does it allow me to do that?


cheers,
Lennert
