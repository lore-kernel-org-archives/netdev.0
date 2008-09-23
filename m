From: David Miller <davem@davemloft.net>
Subject: Re: [patch 7/8] hci_usb: replace mb with smp_mb
Date: Mon, 22 Sep 2008 19:22:07 -0700 (PDT)
Message-ID: <20080922.192207.178559086.davem@davemloft.net>
References: <200809222150.m8MLog27031875@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom.leiming@gmail.com,
	hidave.darkstar@gmail.com, marcel@holtmann.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60631
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754209AbYIWCWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:22:19 -0400
In-Reply-To: <200809222150.m8MLog27031875@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 22 Sep 2008 14:50:42 -0700

> smp_mb is enough for ordering memory operations among processors,and mb is
> more expensive than smp_mb for UP machine, so replace it with smp_mb().
> 
> Signed-off-by: Ming Lei <tom.leiming@gmail.com>
> Acked-by: Marcel Holtmann <marcel@holtmann.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Since this already ACK'd by Marcel, I've added this to net-next-2.6
