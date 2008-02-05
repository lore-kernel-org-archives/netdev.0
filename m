From: David Miller <davem@davemloft.net>
Subject: Re: [patch 7/7] rfcomm tty: destroy before tty_close()
Date: Tue, 05 Feb 2008 03:12:17 -0800 (PST)
Message-ID: <20080205.031217.260374399.davem@davemloft.net>
References: <200802050748.m157m1v2010470@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, netdev@vger.kernel.org,
	hidave.darkstar@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35639
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757097AbYBELLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 06:11:49 -0500
In-Reply-To: <200802050748.m157m1v2010470@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 04 Feb 2008 23:48:20 -0800

> From: Dave Young <hidave.darkstar@gmail.com>
> 
> rfcomm dev could be deleted in tty_hangup, so we must not call
> rfcomm_dev_del again to prevent from destroying rfcomm dev before tty
> close.
> 
> Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
> Cc: Marcel Holtmann <marcel@holtmann.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied, thanks.
