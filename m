From: "junk" <junk@toutatis.be>
Subject: ipt_ROUTE and destination MAC address
Date: Fri, 11 Feb 2005 13:39:38 +0100
Message-ID: <20050211123718.M74819@toutatis.be>
References: <S262133AbVBJPBt/20050210150149Z+8411@vger.kernel.org>
Reply-To: "junk" <junk@toutatis.be>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=iso-8859-1
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

i'm coding a virtual interface. That virtual interface has to receive packets
coming on eth0. For that purpose, i'm using ipt_ROUTE. That works great, i can
see my packets arriving on red0 (my virtual interface).

But there is a problem..

If i send an icmp request to 10.0.1.1 from another computer:

The icmp request arrives on the physical interface, ROUTE target makes it
arrive on red0

icmp request arriving on red0: 10.0.0.1

The problem is that the destination MAC is the one of eth0, so, it seems the
kernel doesn't really deliver the packet to my driver. I can see it in tcpdump
but my driver receive function is never called.

I tried every -j ROUTE option, --gw or --iif, with --continue, or not..

Any idea?
