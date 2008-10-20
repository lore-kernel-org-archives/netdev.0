From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: change name dropping error codes
Date: Sun, 19 Oct 2008 23:34:03 -0700 (PDT)
Message-ID: <20081019.233403.127810157.davem@davemloft.net>
References: <20081017213006.385c45cd@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32886
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750971AbYJTGe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 02:34:26 -0400
In-Reply-To: <20081017213006.385c45cd@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 17 Oct 2008 21:30:06 -0700

> If changename notifier returns an error code, it gets incorrectly
> cleared during rollback so the error is never returned to the user.
> Found while testing similar code for MTU changes.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks Stephen.
