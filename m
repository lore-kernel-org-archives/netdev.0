From: Wai Yim <wyim@erd.epson.com>
Subject: Anyone having problem modify incoming IP packets at NetFilter Hoo
	k Module PREROUTING?
Date: Thu, 22 May 2003 18:02:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <B084D3D7CC75D61195A600D0B7B8EC22303202@erdexch1.erd.epson.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi All,

I am new to Linux and NetFilter.  I am trying to write a NetFilter Hook
Module that hooks to both POSTROUTING and PREROUTING filter.
All I am trying to do is, if an IP packet is for certain dest IP address, I
will add (POSTROUTING) and take-out (PREROUTING)certain number of
bytes in the packet before I pass on the packet.  The POSTROUTING NetFilter
hook seems working fine.  I can get all of the outgoing 
IP packets, and I can call skb_copy_expand + skb_push for the new data.
>From ethereal, I see correct outgoing packets onto the 
network.  

However, here is the problem, when I get a packet at the PREROUTING, and for
certain packets that are about the size of the MTU, when I
call skb_copy or skb_pull, my entire system freezes right the way!  Upon
further investigation, when the trouble packet arrives, even reading
data from skb->data using memcpy will freeze the system.  I have exhausted
all combination of things that I can try...  Any help, idea, or
direction as what else I should try or where the problem may be will be
deeply appreciated.


Wai
