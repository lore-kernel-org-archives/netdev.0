From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cnic: Add a signature to indicate valid
 doorbell offset.
Date: Wed, 01 Jan 2014 22:08:45 -0500 (EST)
Message-ID: <20140101.220845.701366883207918240.davem@davemloft.net>
References: <1388560714-32561-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45961 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbaABDIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 22:08:46 -0500
In-Reply-To: <1388560714-32561-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>
Date: Tue, 31 Dec 2013 23:18:34 -0800

> From: Eddie Wai <eddie.wai@broadcom.com>
> 
> The buffer that is used to pass doorbell offset to the userspace UIO
> driver may contain nonzero value in older versions of bnx2x driver.
> Userspace cannot easily tell whether it contains a valid doorbell
> offset or not.  With the added signature, userspace will only use
> the doorbell offset if the signature is present.
> 
> Update version to 2.5.19.
> 
> Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
