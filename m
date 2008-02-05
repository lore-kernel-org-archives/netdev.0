From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] hamradio: fix dmascc section mismatch
Date: Tue, 05 Feb 2008 03:04:13 -0800 (PST)
Message-ID: <20080205.030413.152742971.davem@davemloft.net>
References: <200802050745.m157j1qJ010297@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, randy.dunlap@oracle.com,
	klaus.kudielka@gmx.net, sam@ravnborg.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37391
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757680AbYBELDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 06:03:45 -0500
In-Reply-To: <200802050745.m157j1qJ010297@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 04 Feb 2008 23:45:20 -0800

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> hw[] is used in both init and exit functions so it cannot be initdata (section
> mismatch is when CONFIG_MODULES=n and CONFIG_DMASCC=y).
> 
> WARNING: vmlinux.o(.exit.text+0xba7): Section mismatch: reference to .init.data: (between 'dmascc_exit' and 'sixpack_exit_driver')
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> Cc: Klaus Kudielka <klaus.kudielka@gmx.net>
> Cc: Sam Ravnborg <sam@ravnborg.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
