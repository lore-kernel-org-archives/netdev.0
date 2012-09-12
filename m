From: David Miller <davem@davemloft.net>
Subject: Re: [V3 PATCH 9/9] cxgb4vf: Chelsio FCoE offload driver submission
 (header compatibility fixes).
Date: Wed, 12 Sep 2012 01:47:46 -0400 (EDT)
Message-ID: <20120912.014746.636228439025755624.davem@davemloft.net>
References: <1347374347-3852-10-git-send-email-naresh@chelsio.com>
	<20120911.133321.282568248903907762.davem@davemloft.net>
	<50501F1A.6040905@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: JBottomley@parallels.com, linux-scsi@vger.kernel.org,
	dm@chelsio.com, leedom@chelsio.com, netdev@vger.kernel.org,
	chethan@chelsio.com
To: naresh@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754479Ab2ILFrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 01:47:51 -0400
In-Reply-To: <50501F1A.6040905@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Naresh Kumar Inna <naresh@chelsio.com>
Date: Wed, 12 Sep 2012 11:05:22 +0530

> On 9/11/2012 11:03 PM, David Miller wrote:
>> From: Naresh Kumar Inna <naresh@chelsio.com>
>> Date: Tue, 11 Sep 2012 20:09:07 +0530
>> 
>>> This patch contains minor fixes to make cxgb4vf driver work with the updates to
>>> shared firmware/hardware header files.
>>>
>>> Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
>> 
>> You cannot submit a patch set that isn't bisectable, and in particular
>> create a situation that mid-way through your patch set things do not
>> build or operate correctly.
>> 
> 
> Sorry, I am new to this process. The reason I did that was because I was
> not sure if I could create a single patch with both cxgb4 and cxgb4vf
> files in it, since they are two different subsystems. If I could do
> that, the single patch then would build on its own, and not be dependent
> on the other patches in the series. Is that something I can do?

I don't know how else to say this, every step along the way the tree
has to build.  You arrange the patches however necessary to achieve
that goal.
