From: Olaf Hering <olh@suse.de>
Subject: optional hwchecksum in sungem
Date: Sun, 12 Dec 2004 15:34:01 +0100
Message-ID: <20041212143401.GA21262@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David,

the harddrive in my ibook was broken and they replaced it.
Somehow they managed to break the trackpad and sungem.
The trackpad works sometimes, sometimes not. The sungem needs now 
skb->ip_summed set to 0 and networking works fine again.

Today I wondered why none of my iptables rules matched anymore with
2.6.10 (worked with 2.6.8). It turned out that most of the traffic
matched a rule:
iptables -I INPUT -i ppp0 -m state --state INVALID -j LOG

I cant imagine how they crippled the network and the trackpad. Do you
know why ethtool can not turn off rx checksumming? Is it just not
implemented, or is it not tunable during runtime? 
ethtool -k eth0 doesnt work for sungem.
Would you accept a patch to make ->ip_summed a module option?
