From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: scm: moving dereference after NULL check
Date: Mon, 24 Sep 2012 15:51:48 -0400 (EDT)
Message-ID: <20120924.155148.1513263823536378183.davem@davemloft.net>
References: <20120923170330.GA5038@linux-3ix0.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cxzhang@watson.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: maxin.john@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120923170330.GA5038@linux-3ix0.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Maxin B. John" <maxin.john@gmail.com>
Date: Sun, 23 Sep 2012 13:03:30 -0400

> scm_destroy_cred() dereferences 'scm' before null check
> 
> Signed-off-by: Maxin B. John <maxin.john@gmail.com>

Every caller of scm_destroy() passes a non-NULL scm, so the
NULL test can be removed entirely.

I'll do this in net-next, thanks.
