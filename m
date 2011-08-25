From: Rick Jones <rick.jones2-VXdhtT5mjnY@public.gmane.org>
Subject: is SO_PRIORITY still supposed to affect the TOS field?
Date: Thu, 25 Aug 2011 14:52:05 -0700
Message-ID: <4E56C405.3030407@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, amirv-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org,
	mkt.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Amir Vadai recently sent me some patches for netperf to implement 
setting SO_PRIORITY.  I made changes to netperf based on those patches, 
(now in top of trunk on netperf.org) and between some emails with me, 
him and Dave Taht and some quick messing around while watching tcpdump, 
I'm wondering if this:

>       SO_PRIORITY
>               Set the protocol-defined priority for all packets to be sent  on
>               this  socket.   Linux  uses  this  value to order the networking
>               queues: packets with a higher priority may  be  processed  first
>               depending  on  the  selected  device  queueing  discipline.  For
>               ip(7), this also sets the IP  type-of-service  (TOS)  field  for
>               outgoing  packets.   Setting a priority outside the range 0 to 6
>               requires the CAP_NET_ADMIN capability.

from the socket(7) manpage is still accurate because even setting a 
number of different values for SO_PRIORITY I didn't see the TOS field as 
anything other than 0 in tcpdump output (confirming something Dave Taht 
saw).

happy benchmarking,

rick jones
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
