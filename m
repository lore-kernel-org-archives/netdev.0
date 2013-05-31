From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next 0/6] net/core, bonding: dev_uc_sync fixes, bonding update
Date: Fri, 31 May 2013 08:56:30 -0700
Message-ID: <26013.1370015790@death.nxdomain>
References: <1369961744-21460-1-git-send-email-fubar@us.ibm.com> <20130531.013155.25881045915195152.davem@davemloft.net> <20130531152812.GB2910@sbohrermbp13-local.rgmadvisors.com>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	vyasevic@redhat.com
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:38676 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753869Ab3EaP5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 11:57:06 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 31 May 2013 09:57:04 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 31F9B19D804E
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 09:56:42 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4VFuWBP152522
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 09:56:33 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4VFuVPp023672
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 09:56:32 -0600
In-reply-to: <20130531152812.GB2910@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shawn Bohrer <shawn.bohrer@gmail.com> wrote:

>On Fri, May 31, 2013 at 01:31:55AM -0700, David Miller wrote:
>> From: Jay Vosburgh <fubar@us.ibm.com>
>> Date: Thu, 30 May 2013 17:55:38 -0700
>> 
>> > 	This patch set includes 6 patches: four fixes to the dev_mc_sync /
>> > dev_mc_unsync system; and two patches to bonding, one to utilize the sync
>> > / unsync functions, and another minor fix related to MAC address handling.
>> 
>> These look like fixes that should go into net, why target net-next?
>
>In my oppinion 0-4 should go into net since they fix the bug I
>reported in:
>
>http://comments.gmane.org/gmane.linux.network/270477
>
>I've tested patches 0-4 of this series so feel free to add my tested
>by to those:
>
>Tested-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
>
>From just a casual observation of patch 5-6 they do not appear to be
>bug fixes which is why this was probably marked net-next.

	They're against net-next because I was working to convert
bonding to dev_sync/unsync against net-next and neglected to rebase then
before I posted.  The bonding patches (5 and 6) do fix a couple of bugs
related to MAC address handling on s390 (the lack of additional unicast
address propagation to the slaves makes qeth unhappy in some cases), so
arguably they could go either way, but I'm ok with those in net-next if
it's an issue.

	I do agree that 1-4 should go into net, once Vlad gives them a
look.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
