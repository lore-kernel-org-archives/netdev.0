From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: add missing unlock in tg3_open() error path
Date: Tue, 21 Nov 2006 17:44:49 -0800 (PST)
Message-ID: <20061121.174449.88702984.davem@davemloft.net>
References: <20061121142311.4d1b9510.kernel@irasnyder.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:6822
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161750AbWKVBou (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Nov 2006 20:44:50 -0500
To: kernel@irasnyder.com
In-Reply-To: <20061121142311.4d1b9510.kernel@irasnyder.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ira Snyder <kernel@irasnyder.com>
Date: Tue, 21 Nov 2006 14:23:11 -0800

> [PATCH] tg3: add missing unlock in tg3_open() error path
> 
> Sparse noticed a locking imbalance in tg3_open(). This patch adds an unlock
> to one of the error paths, so that tg3_open() always exits without the
> lock held.
> 
> Signed-off-by: Ira W. Snyder <kernel@irasnyder.com>

Nice catch.  Patch applied, thanks a lot.
