From: Xu Nakajima <xunakaj@yahoo.com>
Subject: RtNetlink in wireless.c and netlink_broadcast(uevent_sock,...) - newbie
Date: Sun, 30 Apr 2006 12:14:56 -0700 (PDT)
Message-ID: <20060430191456.80796.qmail@web38310.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from web38310.mail.mud.yahoo.com ([209.191.125.26]:39590 "HELO
	web38310.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S1750984AbWD3TO6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Apr 2006 15:14:58 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I saw that in the wireless linux stack, there is usage

of sending messages to user space via the RtNetlink
event channel : 
in net/core/wireless.c,  wireless_send_event() method
calls rtmsg_iwinfo() which calls
netlink_broadcast(rtnl, skb, 0, RTNLGRP_LINK,
GFP_ATOMIC); (it fills a struct with 
rtnetlink_fill_iwinfo before).

On the other hand, I see that for example, in the case
of 
sending messeges to userspace udev socket, the
netlink_broadcast() call is with a different
mecahinsm;  
In lib/kobject_uevent.c, there is the following call
netlink_broadcast(uevent_sock, skb, 0, 1, GFP_KERNEL);

Is there something special about RtNetlink event
channel
which makes it needed fot wireless.c (for example)? 
While udev can use some other mechanism ?
What is special about RtNetlink event channel
in comaprison to non RtNetlink channels?

Regards,
Xu



__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
