From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/5 net-next v2] tg3: Fix inconsistent locking for
 tg3_netif_start().
Date: Tue, 4 Dec 2012 09:48:23 +0100
Message-ID: <20121204084821.GA2223@netboy.at.omicron.at>
References: <1354599420-3589-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, nsujir@broadcom.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:33514 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829Ab2LDIsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 03:48:36 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so2089046eek.19
        for <netdev@vger.kernel.org>; Tue, 04 Dec 2012 00:48:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1354599420-3589-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 03, 2012 at 09:36:56PM -0800, Michael Chan wrote:
> From: Nithin Nayak Sujir <nsujir@broadcom.com>
> 
> Every caller holds tp->lock when calling tg3_netif_start() except
> tg3_io_resume().  Fix it so that it is all consistent.  The subsequent
> PTP patches add tg3_ptp_resume() to tg3_netif_start() and the tp->lock
> is required.
> 
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

This series looks good to me now.

Acked-by: Richard Cochran <richardcochran@gmail.com>
