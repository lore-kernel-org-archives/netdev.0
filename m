From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] [net-next] qlge: Change frame route hw semaphore
 granularity.
Date: Tue, 24 Feb 2009 23:51:45 -0800 (PST)
Message-ID: <20090224.235145.27874589.davem@davemloft.net>
References: <1235421737-32296-1-git-send-email-ron.mercer@qlogic.com>
	<1235421737-32296-3-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49397
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758634AbZBYHwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 02:52:04 -0500
In-Reply-To: <1235421737-32296-3-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Mon, 23 Feb 2009 12:42:15 -0800

> Instead of taking/giving the hw semaphore repeatedly when iterating over
> several frame to queue route settings, we have the caller hold it until
> all are done.
> This reduces PCI bus chatter and possible waits.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.
