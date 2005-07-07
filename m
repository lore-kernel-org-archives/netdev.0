From: Christian Schmid <webmaster@rapidforum.com>
Subject: Bug still exists...
Date: Thu, 07 Jul 2005 17:51:43 +0200
Message-ID: <42CD4F8F.9060503@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi.

The vm slow-down bug starting at 4000 sockets still exists. I now have finally traced the issue 
down. It depends on the number of sockets AND the bandwidth you need. So I suppose it depends on the 
number of packets flowing through the NIC. I managed to completely remove the bug by using two cards 
and the nexthop-parameter to use eth0 and eth1 with the same gateway-ip. Maybe interrupt-problems? 
Slow-down appears on intel and broadcom cards. Other cards not tested.

Chris
