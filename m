From: John Sigler <linux.kernel@free.fr>
Subject: neigh: timer & !nud_in_timer
Date: Thu, 20 Dec 2007 14:35:01 +0100
Message-ID: <476A6F85.7070905@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-rt-users@vger.kernel.org
Return-path: <linux-rt-users-owner@vger.kernel.org>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I noticed the following message in my kernel log.
kernel: neigh: timer & !nud_in_timer
(Might be due to a race condition.)

I'm running a UP Linux version 2.6.22.1-rt9
( http://rt.wiki.kernel.org/index.php )

The following /proc entries might be relevant.

/proc/sys/net/ipv4/conf/all/arp_accept
0
/proc/sys/net/ipv4/conf/all/arp_announce
2
/proc/sys/net/ipv4/conf/all/arp_filter
0
/proc/sys/net/ipv4/conf/all/arp_ignore
1

I also lowered the priority of softirq-timer/0 to 10 which means
it can be interrupted by other IRQ handlers.

Regards.
