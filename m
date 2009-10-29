From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Cleanup redundant tests on unsigned
Date: Thu, 29 Oct 2009 01:40:24 -0700 (PDT)
Message-ID: <20091029.014024.29284045.davem@davemloft.net>
References: <4AE1CA14.10304@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eis@baty.hanse.de,
	linux-x25@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <linux-x25-owner@vger.kernel.org>
In-Reply-To: <4AE1CA14.10304@gmail.com>
Sender: linux-x25-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roel Kluin <roel.kluin@gmail.com>
Date: Fri, 23 Oct 2009 17:21:56 +0200

> If there is data, the unsigned skb->len is greater than 0.
> 
> rt.sigdigits is unsigned as well, so the test `>= 0' is
> always true, the other part of the test catches wrapped
> values.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.
