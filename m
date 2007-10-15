From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH V7 0/8] net/bonding: ADD IPoIB support for the bonding driver
Date: Mon, 15 Oct 2007 13:34:46 -0700
Message-ID: <27349.1192480486@death>
References: <47138EB7.40703@gmail.com> <4713B006.9090908@pobox.com>
Cc: Moni Shoua <monisonlists@gmail.com>, rdreier@cisco.com,
	netdev@vger.kernel.org, general@lists.openfabrics.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:54545 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755397AbXJOUez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 16:34:55 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9FKYnmN024574
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 16:34:49 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9FKYnoO430222
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 14:34:49 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9FKYmD1029186
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 14:34:49 -0600
In-reply-to: <4713B006.9090908@pobox.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> wrote:

>Moni Shoua wrote:
>> This is the 7th version of this patch series. See link to V6 below.
>>
>> Changes from the previous version
>> ---------------------------------
>>
>> * Some patches required modifications to remove offsets so they can be applied with git-apply
>> * Patch #3 was first modified by Jay and later by me to make it work with header_ops
>> * patch #8 was changed to fix the problem that caused 'ifconfig down' to stuck (dev_close was called twice)
>
>I just applied the latest version Jay sent, are there any remaining changes?

	Yes, Moni changed patches 3 and 8 from the series I posted to
fix a couple of problems.  The others aren't changed from my posting of
the series.

	Since I see you've just pushed it, do you want a patch to
correct just the two individual things, or would you rather have new
patches?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
