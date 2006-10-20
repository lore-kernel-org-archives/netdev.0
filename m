From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [RFC] wrr (weighted round-robin) bonding
Date: Fri, 20 Oct 2006 14:55:17 -0700
Message-ID: <200610202155.k9KLtHZt027739@death.nxdomain.ibm.com>
References: <200610162021.12884.dpc@asn.pl> <200610202141.15140.dpc@asn.pl> <200610201953.k9KJr2Zt000305@death.nxdomain.ibm.com> <200610202252.01390.dpc@asn.pl>
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:59057 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S2992768AbWJTVzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:55:20 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9KLtJlg005321
	for <netdev@vger.kernel.org>; Fri, 20 Oct 2006 17:55:19 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9KLtJb8129148
	for <netdev@vger.kernel.org>; Fri, 20 Oct 2006 17:55:19 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9KLtJgJ008516
	for <netdev@vger.kernel.org>; Fri, 20 Oct 2006 17:55:19 -0400
To: Dawid Ciezarkiewicz <dpc@asn.pl>
In-reply-to: <200610202252.01390.dpc@asn.pl> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dawid Ciezarkiewicz <dpc@asn.pl> wrote:
[...]
>Oh. I'm quite puzzled here. What is current policy? I'd like sysfs interfaces 
>better than ioctl - they are much cleaner etc. - but I thought ioctl will be 
>better here because current bonding control uses ioctl and extending it is 
>much simpler.

	The bonding control stuff is (slowly but surely) moving to
sysfs.  There really isn't anything you can't do to bonding via sysfs
now; the only real issue is that it's difficult to get success / failure
status from a sysfs request.

>More generally: should I use sysfs always when adding anything to kernel and 
>use it even when extending older functionality?

	Well, I can't speak for the kernel as a whole, but for bonding,
I see no reason to add any new functionality to ifenslave at this point
in time, including new ioctl paths into the driver.

>If wrr bonding have chances for inclusion into mainline I'll do any necessary 
>changes to let it meet requirements. I'd like to know if functionality from 
>Andy's patch is desired to be a part of such round-robin bonding extension. I 
>think I could easily integrate it with wrr.

	I'm unfamiliar with Andy's patch (other than his description).
If there's interest in, and justification for, functionality to
manipulate the way the round-robin mode doles out packets it would be
best to have a single, generic dingus rather that two special-purpose
thingies.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
