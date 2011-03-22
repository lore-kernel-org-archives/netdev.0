From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: fix possible oops on l2tp_eth module unload
Date: Mon, 21 Mar 2011 18:10:49 -0700 (PDT)
Message-ID: <20110321.181049.70195711.davem@davemloft.net>
References: <201103210926.p2L9QQBd009047@bert.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48142
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755028Ab1CVBKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 21:10:11 -0400
In-Reply-To: <201103210926.p2L9QQBd009047@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Mon, 21 Mar 2011 09:26:26 GMT

> A struct used in the l2tp_eth driver for registering network namespace
> ops was incorrectly marked as __net_initdata, leading to oops when
> module unloaded.
 ...
> Signed-off-by: James Chapman <jchapman@katalix.com>

Applied, thanks James.

> Push to stable trees too?

Yep I'll take care of that.
