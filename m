From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/1] qlge: Fix deadlock when cancelling worker.
Date: Sun, 12 Dec 2010 15:04:15 -0800 (PST)
Message-ID: <20101212.150415.116377489.davem@davemloft.net>
References: <4CF95995.1070506@gmail.com>
	<1292101610-30661-1-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarkao2@gmail.com, mingo@elte.hu,
	Linux-Driver@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41900
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752060Ab0LLXDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Dec 2010 18:03:47 -0500
In-Reply-To: <1292101610-30661-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Sat, 11 Dec 2010 13:06:50 -0800

> Removing usage of rtnl_lock() to protect firmware interface registers.
> These registers are accessed in some worker threads and can create a
> deadlock if rtnl_lock is taken by upper layers while the worker is still
> pending.
> We remove rtnl_lock and use a driver mutex just while mailboxes are
> accessed.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.
