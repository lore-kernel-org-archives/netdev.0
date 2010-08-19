From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [patch] qlge: pull NULL check ahead of dereference
Date: Thu, 19 Aug 2010 05:19:42 -0700
Message-ID: <20100819121942.GA14895@linux-ox1b.qlogic.org>
References: <20100819100214.GB6674@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Driver <Linux-Driver@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>,
	Breno Leitao <leitao@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:55667 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750890Ab0HSNE6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 09:04:58 -0400
Content-Disposition: inline
In-Reply-To: <20100819100214.GB6674@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 19, 2010 at 03:02:15AM -0700, Dan Carpenter wrote:
> There was a dereference before NULL check issue introduced in 1e213303d
> "qlge: Add tx multiqueue support."  I've pulled the NULL check of
> "net_rsp" forward a couple lines to restore the original semantics.
>

net_rsp is initialized to NULL and will never be NULL if entries are
processed.  It should be fine as it is currently coded.

