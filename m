From: Parag Nemade <cranium2003@yahoo.com>
Subject: ping takes much time to myself?
Date: Mon, 26 Apr 2004 08:44:37 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040426154437.67657.qmail@web41402.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernerl mail <linux-kernel@vger.kernel.org>,
	linux net <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: net dev <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

hello,
     i want to add my own variables with icmp header.
so i modified icmp header and added 2 variables to
make icmp header len is 16 bytes. but when i build
kernel image and boot it and then ping to myself why
am i still getting 8 bytes header i.e. 84 bytes packet
and why not 92 bytes packet?
56 bytes data + 16 bytes icmp header + 20 bytes ip
header = 92 bytes
also ping results shown below takes much time to ping
myself. what gone wrong? how to make it behave like
normal ping?

[root@localhost root]# ping localhost
PING localhost.localdomain (127.0.0.1) 56(84) bytes of
data.
64 bytes from localhost.localdomain (127.0.0.1):
icmp_seq=1 ttl=64 time=1488806
ms
64 bytes from localhost.localdomain (127.0.0.1):
icmp_seq=2 ttl=64 time=1489805
ms

--- localhost.localdomain ping statistics ---
2 packets transmitted, 2 received, 0% packet loss,
time 999ms
rtt min/avg/max/mdev =
1488806.484/1489305.976/1489805.469/500.981 ms
[root@localhost root]#
regards,
parag.


	
		
__________________________________
Do you Yahoo!?
Yahoo! Photos: High-quality 4x6 digital prints for 25¢
http://photos.yahoo.com/ph/print_splash
