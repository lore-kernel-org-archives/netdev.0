From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] [net-next] qlge: Increase MAC addr hw sem
 granularity.
Date: Tue, 24 Feb 2009 23:51:39 -0800 (PST)
Message-ID: <20090224.235139.20779954.davem@davemloft.net>
References: <1235421737-32296-1-git-send-email-ron.mercer@qlogic.com>
	<1235421737-32296-2-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49394
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758106AbZBYHv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 02:51:58 -0500
In-Reply-To: <1235421737-32296-2-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Mon, 23 Feb 2009 12:42:14 -0800

> Instead of taking/giving the semaphore repeatedly when iterating over
> several adderesses, we have the caller hold it until all are done.  This
> reduces PCI bus chatter and possible waits.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.

