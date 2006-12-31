From: Komuro <komurojun-mbn@nifty.com>
Subject: Re: [BUG KERNEL 2.6.20-rc1] ftp: get or put stops during
 file-transfer
Date: Sun, 31 Dec 2006 18:42:47 +0900
Message-ID: <20061231184247.0b68cede.komurojun-mbn@nifty.com>
References: <20061230185043.d31d2104.komurojun-mbn@nifty.com>
	<20061230.102358.106876516.yoshfuji@linux-ipv6.org>
	<20061230205931.9e430173.komurojun-mbn@nifty.com>
	<20061230.231952.16573563.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, jgarzik@pobox.com, viro@ftp.linux.org.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg500.nifty.com ([202.248.238.80]:18979 "EHLO
	userg500.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932233AbWLaAnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Dec 2006 19:43:42 -0500
To: YOSHIFUJI Hideaki / =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <20061230.231952.16573563.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Can you reproduce it with other ftp client and/or server?
 
O.K. I wiil try to test other ftp client and server.
 

> Please provide the output of "netstat -na" command during the
> transfer, and the output of "lsmod | grep conntrack" (just for
> sure).

Please see the output of "netstat -na" when stuck. (below)

CONFIG_NETFILER is diabled in my test configuration
,conntrack modules is not loaded.
(CONFIG_IP_DCCP, CONFIG_IP_SCTP, CONFIG_TIPC, CONFIG_IPV6 is
also disabled) 

 
> What kind of mode do you use? e.g. PORT/EPRT/LPRT/PASV/EPSV/LPSV

PASV mode.
 
> When the transfer get stuck, are other communication still working?

Other communication works properly.
Actually, I can start other ftp session on other console of the same PC.

> Are there any workaround?
> e.g. stop-start vsftpd cycle, ifdown-ifup cycle, rmmod/insmod cycle etc.

I only need to do the killall command.


>> output of netstat -na

Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address               Foreign Address             State      
tcp        0      0 0.0.0.0:873                 0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:111                 0.0.0.0:*                   LISTEN      
tcp        0      0 192.168.0.6:35737           192.168.0.2:26827           TIME_WAIT   
tcp        0      0 192.168.0.6:51036           192.168.0.2:21              ESTABLISHED 
udp        0      0 0.0.0.0:68                  0.0.0.0:*                               
udp        0      0 0.0.0.0:867                 0.0.0.0:*                               
udp        0      0 0.0.0.0:870                 0.0.0.0:*                               
udp        0      0 0.0.0.0:111                 0.0.0.0:*                               
Active UNIX domain sockets (servers and established)
Proto RefCnt Flags       Type       State         I-Node Path
unix  2      [ ACC ]     STREAM     LISTENING     5056   /tmp/.font-unix/fs7100
unix  2      [ ]         DGRAM                    1234   @/org/kernel/udev/udevd
unix  5      [ ]         DGRAM                    4748   /dev/log
unix  2      [ ACC ]     STREAM     LISTENING     4917   /var/run/dbus/system_bus_socket
unix  2      [ ACC ]     STREAM     LISTENING     4989   /var/run/acpid.socket
unix  2      [ ]         DGRAM                    5390   
unix  3      [ ]         STREAM     CONNECTED     4920   
unix  3      [ ]         STREAM     CONNECTED     4919   
unix  2      [ ]         DGRAM                    4866   
unix  2      [ ]         DGRAM                    4756   



Thanks,

Best Regards
Komuro

