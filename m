From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] iscsi: Use GFP_ATOMIC in iscsi_offload_mesg().
Date: Thu, 30 Jul 2009 11:04:18 -0700 (PDT)
Message-ID: <20090730.110418.14002042.davem@davemloft.net>
References: <4A70058F.50403@cs.wisc.edu>
	<1248893392.16148.262.camel@HP1>
	<4A70FA22.7010706@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: open-iscsi@googlegroups.com, James.Bottomley@HansenPartnership.com,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org
To: michaelc@cs.wisc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45745
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751946AbZG3SEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 14:04:10 -0400
In-Reply-To: <4A70FA22.7010706@cs.wisc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Christie <michaelc@cs.wisc.edu>
Date: Wed, 29 Jul 2009 20:40:50 -0500

> On 07/29/2009 01:49 PM, Michael Chan wrote:
>> Changing to GFP_ATOMIC because the only caller in cnic/bnx2i may
>> be calling this function while holding spin_lock.
>>
>> This problem was discovered by Mike Christie.
>>
>> Signed-off-by: Michael Chan<mchan@broadcom.com>
 ...
> Acked-by: Mike Christie <michaelc@cs.wisc.edu>
> 
> Dave Miller probably wants to take this in his tree since it fixes a
> bug with this patch
> http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=6d7760a88c25057c2c2243e5dfe2d731064bd31d

Yep I'll take it, thanks everyone.
