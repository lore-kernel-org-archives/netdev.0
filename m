From: bob@kunk.qbjnet.com
Subject: AX25 driver appears broken in PPC 2.6.x
Date: Mon, 27 Sep 2004 12:10:11 -0500 (CDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927171011.20025.qmail@kunk.qbjnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It looks to me like there is a problem with the AX25 code in 2.6 PPC
machines.

I tested both a YAM modem and a KISS serial TNC with an x86 box running
2.6.7 and a couple of different PPC boxes also running 2.6.7 as well as
trying 2.4.27 on the PPC boxes too.

These boxes are running the same version of debian linux (sarge) and have
as close as possible equivalent kernels. 

Using the ax25 call command (i.e. call N0TL-3) I can get connections with
both the PPC and x86 2.6.7 systems. HOWEVER the TCP/IP stack only seems to
work with ax25 on the x86 box. Same hardware, same software, same configuration.

If I drop the PPC kernel back to 2.4.27, it works perfect.

With 2.6.7 on the PPC box, it appears that received packets are being ignored
or routed incorrectly somehow (the routing tables are the same though).
Doing a simple test using ping, I can see the incoming echo reply packets
using listen on the appropriate ax25 port however they seem to be going
into the bitbucket as fas as TCP/IP is concerned.

Regards,
Bob
-- 
/~\ The ASCII       | Robert E. Brose II    N0QBJ
\ / Ribbon Campaign | http://www.qbjnet.com/
 X  Help cure       | bob (at) qbjnet.com  
/ \ HTML Email      | public key at http://www.qbjnet.com/key.html
