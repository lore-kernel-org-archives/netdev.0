From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/7] bluetooth: uninlining
Date: Tue, 05 Feb 2008 03:08:10 -0800 (PST)
Message-ID: <20080205.030810.110354884.davem@davemloft.net>
References: <200802050747.m157lueQ010449@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46093
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756567AbYBELHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 06:07:42 -0500
In-Reply-To: <200802050747.m157lueQ010449@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 04 Feb 2008 23:48:15 -0800

> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Remove all those inlines which were either a) unneeded or b) increased code
> size.
> 
>           text    data     bss     dec     hex filename
> before:   6997      74       8    7079    1ba7 net/bluetooth/hidp/core.o
> after:    6492      74       8    6574    19ae net/bluetooth/hidp/core.o
> 
> Cc: Marcel Holtmann <marcel@holtmann.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
