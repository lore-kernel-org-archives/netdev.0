From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Bad: scheduling while atomic! in 2.6.8.1
Date: Wed, 8 Sep 2004 23:42:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409082342.37273.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

We see the exactly the same with 2.6.8.1.

Our host has 3 nics (all 3 are intel e100). We are using vlan, iptables (no 
nat or connection tracking, though) and ipsec. We tested it on other hardware 
(different mainboard, different nics) and the problem remains.

We are getting the log for every received packet, doesn't matter if these are 
dhcp-requests, pings or something else.

Kernel 2.6.7-rc2 works fine. We didn't test other kernels yet.

Wolfgang Walter
