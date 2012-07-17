From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2: Try to recover from PCI block reset
Date: Mon, 16 Jul 2012 23:12:27 -0700 (PDT)
Message-ID: <20120716.231227.64964536904158545.davem@davemloft.net>
References: <1342484756-29615-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46583 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287Ab2GQGM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 02:12:28 -0400
In-Reply-To: <1342484756-29615-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 16 Jul 2012 17:25:56 -0700

> If the PCI block has reset, the memory enable bit will be reset and
> the device will not respond to MMIO access.  bnx2_reset_task() currently
> will not recover when this happens.  Add code to detect this condition
> and restore the PCI state.  This scenario has been reported by some
> users.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Michael.
