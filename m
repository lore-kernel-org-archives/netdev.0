From: Takashi Hibi <hibi665@oki.com>
Subject: UDP counter doesn't increase
Date: Thu, 19 Feb 2004 11:00:35 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040219110035.2e1c15b4%hibi665@oki.com>
Mime-Version: 1.0
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

UdpInDatagram in /proc/net/snmp6 doen't increase when IPv6 multicast 
UDP packets are received.
sock_queue_rcv_skb() is called directly in udpv6_mcast_deliver. I think that
udpv6_queue_rcv_skb() should be called instead of sock_queue_rcv_skb()
as IPv4.

Regards,
Takashi Hibi
