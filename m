From: Christopher Chan <cchan@outblaze.com>
Subject: Network unavailability in 2.6.4
Date: Wed, 31 Mar 2004 11:27:42 +0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <406A3AAE.3030508@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, I have a box running 2.6.4 which from time to time will become 
unavailable. Each of those times would have corresponding logs in messages.

Hardware:
00:04.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] 
(rev 08)

I am using the e100 driver.


The current resolution is to reboot the box.


logs in /var/log/messages:

Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1635)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1635)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1635)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1635)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1635)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1635)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1635)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1635)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1635)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1635)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1635)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1635)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1635)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1635)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1635)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1635)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1635)
Mar 30 22:50:34 spf6 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1571)
Mar 30 23:34:28 spf6 syslogd 1.4.1: restart.
Mar 30 23:34:28 spf6 syslog: syslogd startup succeeded
