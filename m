From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next 0/6] net/core, bonding: dev_uc_sync fixes, bonding update
Date: Fri, 31 May 2013 10:27:21 -0700
Message-ID: <26571.1370021241@death.nxdomain>
References: <1369961744-21460-1-git-send-email-fubar@us.ibm.com> <20130531.013155.25881045915195152.davem@davemloft.net> <20130531152812.GB2910@sbohrermbp13-local.rgmadvisors.com> <26013.1370015790@death.nxdomain> <51A8C969.5090005@redhat.com>
Cc: Shawn Bohrer <shawn.bohrer@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:38729 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061Ab3EaR1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 13:27:38 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 31 May 2013 11:27:37 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 4D03819D8051
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 11:27:27 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4VHRQIu132652
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 11:27:26 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4VHRMEu011672
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 11:27:23 -0600
In-reply-to: <51A8C969.5090005@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich <vyasevic@redhat.com> wrote:

>On 05/31/2013 11:56 AM, Jay Vosburgh wrote:
>> Shawn Bohrer <shawn.bohrer@gmail.com> wrote:
>>
>>> On Fri, May 31, 2013 at 01:31:55AM -0700, David Miller wrote:
>>>> From: Jay Vosburgh <fubar@us.ibm.com>
>>>> Date: Thu, 30 May 2013 17:55:38 -0700
>>>>
>>>>> 	This patch set includes 6 patches: four fixes to the dev_mc_sync /
>>>>> dev_mc_unsync system; and two patches to bonding, one to utilize the sync
>>>>> / unsync functions, and another minor fix related to MAC address handling.
>>>>
>>>> These look like fixes that should go into net, why target net-next?
>>>
>>> In my oppinion 0-4 should go into net since they fix the bug I
>>> reported in:
>>>
>>> http://comments.gmane.org/gmane.linux.network/270477
>>>
>>> I've tested patches 0-4 of this series so feel free to add my tested
>>> by to those:
>>>
>>> Tested-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
>>>
>>>From just a casual observation of patch 5-6 they do not appear to be
>>> bug fixes which is why this was probably marked net-next.
>>
>> 	They're against net-next because I was working to convert
>> bonding to dev_sync/unsync against net-next and neglected to rebase then
>> before I posted.  The bonding patches (5 and 6) do fix a couple of bugs
>> related to MAC address handling on s390 (the lack of additional unicast
>> address propagation to the slaves makes qeth unhappy in some cases), so
>> arguably they could go either way, but I'm ok with those in net-next if
>> it's an issue.
>>
>> 	I do agree that 1-4 should go into net, once Vlad gives them a
>> look.
>>
>> 	-J
>
>I've reviewed the patches and ran a quick test.  They look good and fix
>obvious problems.  Thanks to Jay for finding and fixing them.
>
>Reviewed-by: Vlad Yasevich <vyasevic@redhat.com>

	Please hold off applying these.

	I just spotted an error in patch #5, so I'm going to fix that
and respin the set against -net.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
