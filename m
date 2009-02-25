From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] [net-next] qlge: Optimize rx buffer refill process.
Date: Tue, 24 Feb 2009 23:51:50 -0800 (PST)
Message-ID: <20090224.235150.154561526.davem@davemloft.net>
References: <1235421737-32296-1-git-send-email-ron.mercer@qlogic.com>
	<1235421737-32296-4-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49400
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759229AbZBYHwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 02:52:09 -0500
In-Reply-To: <1235421737-32296-4-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Mon, 23 Feb 2009 12:42:16 -0800

> RX Buffers are refilled in chunks of 16 at a time before notifying the
> hardware with a register write.  This can cause several writes to take
> place in a given napi poll call.  This change causes the write to take place
> only once at the end of the call.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.
