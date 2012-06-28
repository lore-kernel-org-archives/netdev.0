From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] cnic: Fix occasional NULL pointer
 dereference during reboot.
Date: Wed, 27 Jun 2012 21:28:53 -0700 (PDT)
Message-ID: <20120627.212853.54576295227852758.davem@davemloft.net>
References: <1340845704-12580-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49506 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751474Ab2F1E2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 00:28:54 -0400
In-Reply-To: <1340845704-12580-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 27 Jun 2012 18:08:19 -0700

> We register with bnx2x before we allocate ctx_tbl structure, so it is
> possible for bnx2x to call cnic_ctl before the structure is allocated.
> This can sometimes cause NULL pointer dereference of cp->ctx_tbl.  We
> fix this by adding simple checking for valid state before proceeding.
> The cnic_ctl call is RCU protected so we don't have to deal with race
> conditions.
> 
> Because of the additional checking, we need to finish the shutdown
> before clearing the CNIC_UP flag.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
