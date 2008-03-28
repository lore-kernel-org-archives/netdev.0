From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/4] bluetooth: replace deprecated RW_LOCK_UNLOCKED
 macros
Date: Fri, 28 Mar 2008 16:17:46 -0700 (PDT)
Message-ID: <20080328.161746.18303028.davem@davemloft.net>
References: <200803282137.m2SLbVuZ011635@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rpjday@crashcourse.ca,
	hidave.darkstar@gmail.com, marcel@holtmann.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59541
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752531AbYC1XRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 19:17:48 -0400
In-Reply-To: <200803282137.m2SLbVuZ011635@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 28 Mar 2008 14:37:31 -0700

> From: "Robert P. J. Day" <rpjday@crashcourse.ca>
> 
> The older RW_LOCK_UNLOCKED macros defeat lockdep state tracing so replace them
> with the newer __RW_LOCK_UNLOCKED macros.
> 
> Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>
> Acked-by: Marcel Holtmann <marcel@holtmann.org>
> Cc: Dave Young <hidave.darkstar@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
