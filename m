From: "Ury N. Stankevich" <ury@bofh.homeunix.org>
Subject: bug in 2.4.20
Date: Fri, 11 Apr 2003 19:37:05 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030411193705.02eeea7f.ury@bofh.homeunix.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hi
i use 2.4.20xfs kernel on my box with 4 eth cards
2 rtl8139 eth0, eth1
2 rtl8029 eth2, eth3

and one time samba fail use eth3 iface and i found...
# ip n ls dev eth3
..
10.103.104.255  nud failed
..
broadcast address appear in arp table
while i have C class network attached.

after
# ip l set eth3 dowm; ip l set eth3 up
all become fine.

any suggestions?

-- 
    Linux registered user #287505
