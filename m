From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Thu, 02 Jul 2009 18:30:32 -0700 (PDT)
Message-ID: <20090702.183032.220239220.davem@davemloft.net>
References: <4A4CEE7F.9060705@nvidia.com>
	<4A4D4BDC.8010304@gmail.com>
	<1FC56210173BB445BD77F608D6FB8D03036AA92EEA@HQMAIL03.nvidia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: AAbdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33806
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751731AbZGCBa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 21:30:26 -0400
In-Reply-To: <1FC56210173BB445BD77F608D6FB8D03036AA92EEA@HQMAIL03.nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <AAbdulla@nvidia.com>
Date: Thu, 2 Jul 2009 18:11:01 -0700

> Our hw only runs on architectures that provide coherency. i.e x86
> 
> I'm fine with keeping it with both napi_schedule_prep() and __napi_schedule() if you want it to be similar to other drivers.

It has nothing to do with "coherency".

Re-read Eric's emails, the race can happen on x86 quite trivially.
