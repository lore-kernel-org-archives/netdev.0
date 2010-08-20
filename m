From: David Miller <davem@davemloft.net>
Subject: Re: [patch v2] qlge: pull NULL check ahead of dereference
Date: Thu, 19 Aug 2010 20:48:18 -0700 (PDT)
Message-ID: <20100819.204818.13765444.davem@davemloft.net>
References: <20100819125933.GB14895@linux-ox1b.qlogic.org>
	<20100819185244.GD6674@bicker>
	<20100819202836.GD17233@linux-ox1b.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, Linux-Driver@qlogic.com,
	leitao@linux.vnet.ibm.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54561
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751338Ab0HTDsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 23:48:02 -0400
In-Reply-To: <20100819202836.GD17233@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Thu, 19 Aug 2010 13:28:36 -0700

> On Thu, Aug 19, 2010 at 11:52:44AM -0700, Dan Carpenter wrote:
>> There was a dereference before NULL check issue introduced in 1e213303d
>> "qlge: Add tx multiqueue support."  I've pulled the NULL check of
>> "net_rsp" forward a couple lines to avoid that.
>> 
>> Also Ron Mercer says that the early exit should be above the index
>> write.  ql_write_cq_idx(rx_ring);
>> 
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied to net-next-2.6, thanks guys.
