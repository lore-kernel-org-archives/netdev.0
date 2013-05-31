From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: 3.10.0-rc2 mlx4 not receiving packets for some multicast groups
Date: Thu, 30 May 2013 17:23:20 -0700
Message-ID: <20365.1369959800@death.nxdomain>
References: <20130524154931.GA9245@sbohrermbp13-local.rgmadvisors.com> <20130524163446.GC9245@sbohrermbp13-local.rgmadvisors.com> <CAJZOPZJwe6xAj7xRK5_BnWN2wNT+oVS329+iYtE4hYTqPMLwJQ@mail.gmail.com> <20130525151347.GB25744@lintop.rgmadvisors.com> <20130528201508.GA6409@sbohrermbp13-local.rgmadvisors.com> <CAJZOPZLZmLi3V-3D_16FZHQLsCsHKZY7ZhvaEH1k=Pw_i+ciwQ@mail.gmail.com> <20130530203113.GA4891@sbohrermbp13-local.rgmadvisors.com> <CAJZOPZ+YSWhz0Hw+BWHeT=cEDqRj-s7uY4M-5CTiXcRgJND_+Q@mail.gmail.com> <51A7BD42.8060504@redhat.com>
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Shawn Bohrer <shawn.bohrer@gmail.com>, netdev@vger.kernel.org,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Jiri Pirko <jiri@resnulli.us>
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:55914 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505Ab3EaAYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 20:24:43 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 30 May 2013 18:24:42 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 61C321FF001E
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 18:18:13 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4V0NN8n144506
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 18:23:23 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4V0NM60024193
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 18:23:23 -0600
In-reply-to: <51A7BD42.8060504@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich <vyasevic@redhat.com> wrote:

>>>      CC: Jiri Pirko <jiri@resnulli.us>
>>>      Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>>>      Signed-off-by: David S. Miller <davem@davemloft.net>
>>>
>>> I've confirmed that reverting this patch on top of 3.10-rc3 allows me
>>> to receive packets on all of my multicast groups without the Mellanox
>>> high_rate_steer option set.
>>
>> OK, impressive debugging... so what do we do from here? Vlad, Shawn
>> observes a regression once this patch is used on a large scale setup
>> that uses many multicast groups (you can read the posts done earlier
>> on this thread), does this rings any bell w.r.t to the actual problem
>> in the patch?
>
>I haven't seen that, but I didn't test with that many multicast groups. I
>had 20 groups working.
>
>I'll take a look and see what might be going on.

	I've actually been porting bonding to the dev_sync/unsync
system, and have a patch series of 4 fixes to various internals of
dev_sync/unsync; I'll post those under separate cover.  It may be that
one or more of those things are the source of this problem (or I might
have it all wrong).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
