From: David Miller <davem@davemloft.net>
Subject: Re: Poorer networking performance in later kernels?
Date: Tue, 19 Apr 2016 12:13:07 -0400 (EDT)
Message-ID: <20160419.121307.1112327654033728204.davem@davemloft.net>
References: <57152600.7000801@hpe.com>
	<SN1PR0301MB19983F545852731CD1410DB9D66C0@SN1PR0301MB1998.namprd03.prod.outlook.com>
	<5716558B.2080103@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pbutler@sonusnet.com, rick.jones2@hpe.com, netdev@vger.kernel.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35533 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933378AbcDSQNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 12:13:09 -0400
In-Reply-To: <5716558B.2080103@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Tue, 19 Apr 2016 17:58:03 +0200

> On 04/19/2016 04:54 PM, Butler, Peter wrote:
> 
>>
>> I think the issue is resolved.  I had to recompile my 4.4.0 kernel
>> with a few options pertaining to the Intel NIC which somehow (?) got
>> left out or otherwise clobbered when I ported my 3.4.2 .config to the
>> 4.4.0 kernel source tree.  With those changes now in I see essentially
>> identical performance with the two kernels.  Sorry for any confusion
>> and/or waste of time here.  My bad.
>>
> 
> Can you please send the relevant changes in the config that caused the
> discussed issue?
> 
> Just in the case other people do a similar kernel upgrade from 3.x to
> a recent kernel and the current defaults lead to this non-optimal
> result.

+1
