From: Hadmut Danisch <hadmut@danisch.de>
Subject: Cisco Aironet Problem
Date: Fri, 6 Jun 2003 18:53:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030606165314.GA12669@danisch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I have a problem with 2.4.20 and my Cisco Aironet 340 
PCMCIA card. When I use the keyboard while traffic is high,
something gets broken in the kernel: Both the keyboard and 
the network device freeze permanently, a reboot is required.

I've reported this bug to the aironet driver team (sourceforge),
but did not receive any feedback. Meanwhile I found a bug
report in the dmesg after a crash. Unfortunately I'm not familiar
with that part of the kernel. Maybe you can give me a hint
what could be the reason for such a bug message in dmesg?

airo: BAP error 4000 2
Warning: kfree_skb passed an skb still on a list (from c01206ea).
kernel BUG at skbuff.c:315!
invalid operand: 0000
CPU:    0
EIP:    0010:[<c01cbe44>]    Not tainted
EFLAGS: 00013286
eax: 00000045   ebx: cfde31c0   ecx: cc6f2000   edx: 00000001
esi: c12f5f84   edi: 00000000   ebp: c12f4000   esp: c12f5f6c
ds: 0018   es: 0018   ss: 0018
Process keventd (pid: 2, stackpage=c12f5000)
Stack: c0238740 c01206ea 00000000 c12f5f84 c01206ea cfde31c0 cc4002e4 cc4002e4 
       00000000 00000000 c0128c83 c02489d0 c12f5fb0 00000000 c12f4560 c12f4570 
       c12f4000 00000001 00000000 c12c9f80 00010000 00000000 00000700 c0128b50 
Call Trace:    [<c01206ea>] [<c01206ea>] [<c0128c83>] [<c0128b50>] [<c0105000>]
  [<c01074ae>] [<c0128b50>]

Code: 0f 0b 3b 01 5f 79 23 c0 8b 5c 24 14 e9 ce fe ff ff 8d 74 26 


regards
Hadmut
