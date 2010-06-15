From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/4] cnic: Fix cnic_cm_abort() error handling.
Date: Tue, 15 Jun 2010 14:24:47 -0700 (PDT)
Message-ID: <20100615.142447.233703509.davem@davemloft.net>
References: <1276628223-27125-2-git-send-email-mchan@broadcom.com>
	<1276628223-27125-3-git-send-email-mchan@broadcom.com>
	<1276628223-27125-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55342
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932481Ab0FOVYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 17:24:36 -0400
In-Reply-To: <1276628223-27125-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 15 Jun 2010 11:57:03 -0700

> Fix the code that handles the error case when cnic_cm_abort() cannot
> proceed normally.  We cannot just set the csk->state and we must
> go through cnic_ready_to_close() to handle all the conditions.  We
> also add error return code in cnic_cm_abort().
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Eddie Wai <waie@broadcom.com>

Applied.
