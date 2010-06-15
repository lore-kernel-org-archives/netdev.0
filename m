From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] cnic: Refactor and fix
 cnic_ready_to_close().
Date: Tue, 15 Jun 2010 14:24:39 -0700 (PDT)
Message-ID: <20100615.142439.258108211.davem@davemloft.net>
References: <1276628223-27125-1-git-send-email-mchan@broadcom.com>
	<1276628223-27125-2-git-send-email-mchan@broadcom.com>
	<1276628223-27125-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55338
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932481Ab0FOVY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 17:24:28 -0400
In-Reply-To: <1276628223-27125-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 15 Jun 2010 11:57:02 -0700

> Combine RESET_RECEIVED and RESET_COMP logic and fix race condition
> between these 2 events and cnic_cm_close().  In particular, we need
> to (test_and_clear_bit(SK_F_OFFLD_COMPLETE, &csk->flags)) before we
> update csk->state.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Eddie Wai <waie@broadcom.com>

Applied.
