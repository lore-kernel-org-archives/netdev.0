From: Tom Parker <tom@rooted.net>
Subject: igmp kernel issues.
Date: Tue, 20 Aug 2002 13:54:39 +0100
Sender: owner-netdev@oss.sgi.com
Message-ID: <4.2.0.58.20020820135148.02f70ed8@193.133.49.25>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: tom@rooted.net
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ive been given this address by Alan Cox in regard to some linux kernel 
networking
issues..  Follows is the original question I put to Alan:

---
Im currently rewriting large parts of mrouted for a custom application.
One of the functions im implementing is a "promiscuous" mode,
where by mrouted will service IGMP requests from any subnet, even
if there is no explicit route for the subnet in the kernel routing tables.

Currently the kernel dosnt seem to pass IGMP reports to user space
unless there is a route for the subnet of the host which the report came
from.

Ive searched through ipmr.c and igmp.c to find where its dropping the
IGMP report but havnt found anything obvious.. Do you know where
it does this?
---

Any additional information on this is greatly appreciated.

Thanks in advance
Tom Parker
