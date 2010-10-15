From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] connector: remove lazy workqueue creation
Date: Fri, 15 Oct 2010 17:06:04 +0400
Message-ID: <20101015130604.GA1751@ioremap.net>
References: <4CB8250A.7040902@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrixpower.ru ([195.178.208.66]:51654 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755765Ab0JONgg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 09:36:36 -0400
Content-Disposition: inline
In-Reply-To: <4CB8250A.7040902@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tejun.

On Fri, Oct 15, 2010 at 11:55:22AM +0200, Tejun Heo (tj@kernel.org) wrote:
> Commit 1a5645bc (connector: create connector workqueue only while
> needed once) implements lazy workqueue creation for connector
> workqueue.  With cmwq now in place, lazy workqueue creation doesn't
> make much sense while adding a lot of complexity.  Remove it and
> allocate an ordered workqueue during initialization.
> 
> This also removes a call to flush_scheduled_work() which is deprecated
> and scheduled to be removed.

Looks good, thank you.
Ack.

-- 
	Evgeniy Polyakov
