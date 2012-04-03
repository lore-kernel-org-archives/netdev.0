From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: /proc/net/dev is funky in 3.3.0
Date: Tue, 03 Apr 2012 08:36:35 +0200
Message-ID: <1333434995.18626.39.camel@edumazet-glaptop>
References: <4F7A7C98.1030103@candelatech.com>
	 <1333431810.18626.37.camel@edumazet-glaptop>
	 <4F7A905B.3080107@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:55202 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977Ab2DCGgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 02:36:39 -0400
Received: by wibhq7 with SMTP id hq7so3372522wib.1
        for <netdev@vger.kernel.org>; Mon, 02 Apr 2012 23:36:38 -0700 (PDT)
In-Reply-To: <4F7A905B.3080107@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-02 at 22:53 -0700, Ben Greear wrote:
> On 04/02/2012 10:43 PM, Eric Dumazet wrote:
> > On Mon, 2012-04-02 at 21:29 -0700, Ben Greear wrote:
> >> Not all entries are shown!
> >>
> >> [root@lanner-i7 lanforge]# cat /proc/net/dev|grep sta59
> >> [root@lanner-i7 lanforge]# ifconfig sta59
> >> sta59     Link encap:Ethernet  HWaddr 00:95:95:00:00:3C
> >>             inet addr:10.111.9.39  Bcast:10.111.255.255  Mask:255.255.0.0
> >>             inet6 addr: fe80::295:95ff:fe00:3c/64 Scope:Link
> >>             UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> >>             RX packets:58103 errors:0 dropped:0 overruns:0 frame:0
> >>             TX packets:26167 errors:0 dropped:0 overruns:0 carrier:0
> >>             collisions:0 txqueuelen:1000
> >>             RX bytes:39494634 (37.6 MiB)  TX bytes:37095540 (35.3 MiB)
> >>
> >> Thanks,
> >> Ben
> >>
> >
> > Could you post "ip link" result ?
> >
> 
> It is below.  Looks like /proc/net/dev is missing 6 entries,
> sta69 being one of them.  See end of the email for some grep
> and |wc results.  Seems easily reproducible, so let me know if
> you want more info.

Hmm, I think I understand, commit f04565ddf52 added a regression here, I
will send a fix.

Thanks
