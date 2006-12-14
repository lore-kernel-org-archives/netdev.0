From: David Miller <davem@davemloft.net>
Subject: Re: [AX.25 5/7] Fix unchecked ax25_linkfail_register uses
Date: Thu, 14 Dec 2006 15:53:04 -0800 (PST)
Message-ID: <20061214.155304.57156573.davem@davemloft.net>
References: <11661361331883-git-send-email-ralf@linux-mips.org>
	<1166136135289-git-send-email-ralf@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59884
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752014AbWLNXxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 18:53:05 -0500
To: ralf@linux-mips.org
In-Reply-To: <1166136135289-git-send-email-ralf@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Thu, 14 Dec 2006 23:42:11 +0100

> ax25_linkfail_register uses kmalloc and the callers were ignoring the
> error value.  Rewrite to let the caller deal with the allocation.  This
> allows the use of static allocation of kmalloc use entirely.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied.
