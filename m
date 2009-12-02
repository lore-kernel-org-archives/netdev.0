From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: EEH is failing with timeout
Date: Wed, 02 Dec 2009 15:37:32 -0800 (PST)
Message-ID: <20091202.153732.41986418.davem@davemloft.net>
References: <1259256709-6976-1-git-send-email-leitao@linux.vnet.ibm.com>
	<C27F8246C663564A84BB7AB34397724218065B984E@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42573
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755792AbZLBXh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 18:37:26 -0500
In-Reply-To: <C27F8246C663564A84BB7AB34397724218065B984E@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 30 Nov 2009 01:40:58 -0800

> leitao@linux.vnet.ibm.com wrote:
> 
>> bnx2 is failing when a PCI error is detected. The error is the
>> following:
>>
>> bnx2: Chip not in correct endian mode
>> bnx2: fw sync timeout, reset code = 404001d
>>
>> This error was caused because the way pci_restore_state() is working
>> after commit 4b77b0a2ba27d64f58f16d8d4d48d8319dda36ff.
>>
>> Signed-off-by: Breno Leitao<leitao@linux.vnet.ibm.com>
> 
> Thanks Breno.
> 
> Acked by: Michael Chan <mchan@broadcom.com>

Applied, thanks everyone.

(Michael: Need to have a "-" there in the "Acked-by" otherwise
	  automated tools won't pick up your ACK.  I know the
	  tools should be more robust, and I fixed it up for
	  you when applying Breno's patch.  It's just FYI...)
