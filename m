From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV4]: Fix compiler error with CONFIG_PROC_FS=n
Date: Tue, 05 Feb 2008 16:34:22 -0800 (PST)
Message-ID: <20080205.163422.122562967.davem@davemloft.net>
References: <1202237034.9289.8.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, den@openvz.org
To: johfel@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33350
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758166AbYBFAdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 19:33:53 -0500
In-Reply-To: <1202237034.9289.8.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johann Felix Soden <johfel@gmx.de>
Date: Tue, 05 Feb 2008 19:43:54 +0100

> From: Johann Felix Soden <johfel@users.sourceforge.net>
> 
> Handle CONFIG_PROC_FS=n in net/ipv4/fib_frontend.c because:
> 
> net/ipv4/fib_frontend.c: In function 'fib_net_init':
> net/ipv4/fib_frontend.c:1032: error: implicit declaration of function 'fib_proc_init'
> net/ipv4/fib_frontend.c: In function 'fib_net_exit':
> net/ipv4/fib_frontend.c:1047: error: implicit declaration of function 'fib_proc_exit'
> 
> Signed-off-by: Johann Felix Soden <johfel@users.sourceforge.net>

I'm pretty sure I merged in a change this morning which fixes
this.

BTW, in general we do not put ifdefs into *.c code to fix stuff
like this, instead we add empty implementations into a header
file which is a better place for ifdef tests.

And that's how the patch which was merged handles this problem.
