From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] [net-next] qlge: Use one path to (re)fill rx
 buffers.
Date: Tue, 24 Feb 2009 23:51:56 -0800 (PST)
Message-ID: <20090224.235156.140738324.davem@davemloft.net>
References: <1235421737-32296-1-git-send-email-ron.mercer@qlogic.com>
	<1235421737-32296-5-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49403
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759472AbZBYHwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 02:52:15 -0500
In-Reply-To: <1235421737-32296-5-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Mon, 23 Feb 2009 12:42:17 -0800

> Currently there are two paths for filling rx buffer queues. One is
> used during initialization and the other during runtime.  This patch
> removes ql_alloc_sbq_buffers() and ql_alloc_lbq_buffers() and replaces
> them with a call to the runtime functions ql_update_lbq() and
> ql_update_sbq().
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.
