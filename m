From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][AX25] ax25_ds_timer: use mod_timer instead of add_timer
Date: Mon, 11 Feb 2008 21:38:45 -0800 (PST)
Message-ID: <20080211.213845.30678443.davem@davemloft.net>
References: <20080206074529.GC4496@ff.dom.local>
	<20080206081509.GD4496@ff.dom.local>
	<20080206091413.GE4496@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org, jann@gmx.de
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37547
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751608AbYBLFiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 00:38:13 -0500
In-Reply-To: <20080206091413.GE4496@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 6 Feb 2008 09:14:13 +0000

> [AX25] ax25_ds_timer: use mod_timer instead of add_timer
> 
> This patch changes current use of: init_timer(), add_timer()
> and del_timer() to setup_timer() with mod_timer(), which
> should be safer anyway.
> 
> 
> Reported-by: Jann Traschewski <jann@gmx.de>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks.
