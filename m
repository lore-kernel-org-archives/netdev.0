From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: sock_diag fixes
Date: Sat, 23 Feb 2013 13:54:52 -0500 (EST)
Message-ID: <20130223.135452.1786757508965940073.davem@davemloft.net>
References: <1361618028-9024-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: minipli@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56959 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755298Ab3BWSyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2013 13:54:54 -0500
In-Reply-To: <1361618028-9024-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>
Date: Sat, 23 Feb 2013 12:13:46 +0100

> Hi Dave,
> 
> this small series fixes an exploitable bug in sock_diag. An unprivileged
> user can send us a netlink message resulting in an out-of-bounds access
> that allows userland to take over control while in kernel mode.
> 
> The first patch fixes the bug and should be pushed to stable. The second
> one is an attempt to cleanup the sock_diag_handlers[] access mess in
> __sock_diag_rcv_msg.
> 
> Please apply!

Series applied, thanks.
