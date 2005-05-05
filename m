From: Christian Schmid <webmaster@rapidforum.com>
Subject: MultiPath Routing
Date: Thu, 05 May 2005 14:16:47 +0200
Message-ID: <427A0EAF.2050402@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Since this seems to be an undocumented feature.... How is this equal-cost multipath supposed to 
work? I just want to send outgoing traffic over two gateways. I tried this:

ip route replace default scope global nexthop via 192.168.0.1 dev eth1 weight 100 nexthop via 
192.168.0.100 dev eth1 weight 100

It it doesnt work. It always uses the last for all download-users (around a few hundreds)

Or is this the wrong way? (2.6.12rc3)

Best regards,
Chris
