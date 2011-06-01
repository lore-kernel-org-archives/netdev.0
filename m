From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [patch net-next-2.6] bonding: allow resetting slave failure counters
Date: Wed, 01 Jun 2011 12:53:33 -0700
Message-ID: <24514.1306958013@death>
References: <16056.1306944819@death> <20110601.120300.130602301077156524.davem@davemloft.net> <4DE68ECB.70802@redhat.com> <20110601.122240.1431839726613846748.davem@davemloft.net>
Cc: fbl@redhat.com, jpirko@redhat.com, netdev@vger.kernel.org,
	andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:49008 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759600Ab1FATx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 15:53:59 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p51JgQQG032082
	for <netdev@vger.kernel.org>; Wed, 1 Jun 2011 13:42:26 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p51JrmlV102400
	for <netdev@vger.kernel.org>; Wed, 1 Jun 2011 13:53:51 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p51DrbF7028247
	for <netdev@vger.kernel.org>; Wed, 1 Jun 2011 07:53:38 -0600
In-reply-to: <20110601.122240.1431839726613846748.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>From: Flavio Leitner <fbl@redhat.com>
>Date: Wed, 01 Jun 2011 16:11:07 -0300
>
>> On 06/01/2011 04:03 PM, David Miller wrote:
>>> From: Jay Vosburgh <fubar@us.ibm.com>
>>> Date: Wed, 01 Jun 2011 09:13:39 -0700
>>> 
>>>> 	The "this dingus was added in version X.Y.Z" is there because
>>>> users sometimes read the most recent version of the documentation (that
>>>> they get from the internet) and then would become confused when their
>>>> older distro driver lacked some option described in the documentation.
>>> 
>>> I disagree with this whole concept, because distros backport features
>>> like this into their kernel and therefore the feature is showing up in
>>> version X.Y.$(Z-20).
>> 
>> It doesn't matter the version if the user can find the feature, so
>> distros backporting features works and that info is not useful at all. 
>> However, when the user doesn't find the feature and search the internet,
>> then that info is helpful.
>
>So how is the user going to find that FC14 has the feature even
>though his FC13 kernel does not?
>
>I'll say it again, this version stuff is completely pointless.
>
>If the user is dabbling with upstream kernels he's a minority,
>and clueful enough to figure out this stuff himself.

	The problem was that users would search the internet for bonding
documentation, and get the version out of the current mainline.  That
document described options not present in their distro kernel, and I got
questions asking why they couldn't enable some option present in
mainline but not their distro kernel.  To try and minimize that
confusion, I started documenting when features were added (by bonding
driver version, not by kernel version).

	Maybe this doesn't make as much difference today (for whatever
reason), but it certainly seemed to help back in the day.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
