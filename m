From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: reset_task is crashing the kernel. Fixing it.
Date: Fri, 18 Dec 2009 20:29:19 -0800 (PST)
Message-ID: <20091218.202919.70193968.davem@davemloft.net>
References: <1260988830.31045.79.camel@nseg_linux_HP1.broadcom.com>
	<1260990759-16236-1-git-send-email-leitao@linux.vnet.ibm.com>
	<1260990909.31045.84.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47569
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754397AbZLSE3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 23:29:18 -0500
In-Reply-To: <1260990909.31045.84.camel@nseg_linux_HP1.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 16 Dec 2009 11:15:09 -0800

> 
> On Wed, 2009-12-16 at 11:12 -0800, leitao@linux.vnet.ibm.com wrote:
>> If bnx2 schedules a reset via the reset_task, e.g., due to a TX
>> timeout, it's possible for the NIC to be disabled with packets
>> pending for transmit.  In this case, napi_disable will loop forever,
>> eventually crashing the kernel.  This patch moves the disable of
>> the device to after the napi_disable call.
>> 
>> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
> 
> Acked-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
