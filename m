From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tg3: Override clock, link aware and link idle
 mode during NVRAM dump
Date: Sat, 24 May 2014 23:40:07 -0400 (EDT)
Message-ID: <20140524.234007.2092002212094016123.davem@davemloft.net>
References: <1400920329-9901-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: prashant@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262AbaEYDkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 23:40:08 -0400
In-Reply-To: <1400920329-9901-1-git-send-email-prashant@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prashant Sreedharan <prashant@broadcom.com>
Date: Sat, 24 May 2014 01:32:09 -0700

> When cable is not present the clock speed of some of the devices is
> reduced based upon power saving mode setting in NVRAM. Due to this
> NVRAM reads take long time to complete as a result CPU soft lockup
> message is seen. Fix is to override clock, disable link aware and link
> idle modes before NVRAM reads and restore them back after the reads
> are complete. During this period also check if the thread needs to be
> rescheduled and if there are any signals to handle.
> 
> Also decrease the NVRAM command execution timeout value to 1ms.
> 
> Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied to net-next, thanks.
