From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [patch 02/21] drivers/net/3c501.c: replace init_module&cleanup_module with module_init&module_exit
Date: Fri, 28 Mar 2008 22:23:41 +0000
Message-ID: <20080328222341.GH10722@ZenIV.linux.org.uk>
References: <200803282141.m2SLfGGa011804@imap1.linux-foundation.org> <20080328214755.GE10722@ZenIV.linux.org.uk> <20080328150710.6a664440.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, jkschind@gmail.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:39447 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897AbYC1WXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 18:23:45 -0400
Content-Disposition: inline
In-Reply-To: <20080328150710.6a664440.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 03:07:10PM -0700, Andrew Morton wrote:

> well...  The probe functions are still called, only they're now called at
> initcall-time as well as from the infamous Space.c.
> 
> So I guess these patches should at least have removed the calls from
> Space.c tables, but iirc things aren't as simple as that.  I don't remember
> why.

Probe order.  As in "ISA crap that really needs to be probed in that order,
or you will get hard hangs on the only few boxen that still have the hardware
in question".
