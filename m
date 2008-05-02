From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] hci_usb.h: fix hard-to-trigger race
Date: Fri, 02 May 2008 16:45:37 -0700 (PDT)
Message-ID: <20080502.164537.178111042.davem@davemloft.net>
References: <200805022039.m42KdtYe013613@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hidave.darkstar@gmail.com, marcel@holtmann.org,
	netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	pavel@ucw.cz, pavel@suse.cz
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33825
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S937571AbYEBXpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 19:45:38 -0400
In-Reply-To: <200805022039.m42KdtYe013613@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 02 May 2008 13:39:55 -0700

> From: Pavel Machek <pavel@ucw.cz>
> 
> If someone tries to _urb_unlink while _urb_queue_head is running, he'll see
> _urb->queue == NULL and fail to do any locking.  Prevent that from happening
> by strategically placed barriers.
> 
> Signed-off-by: Pavel Machek <pavel@suse.cz>
> Cc: Marcel Holtmann <marcel@holtmann.org>
> Cc: Dave Young <hidave.darkstar@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

I know we've been over this, but I'm going to apply this
because as long as the code is in the tree we should take
fixes to identifyable problems.
