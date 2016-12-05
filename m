From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: irda: set error code on failures
Date: Mon, 05 Dec 2016 14:53:28 -0500 (EST)
Message-ID: <20161205.145328.1580734576600372225.davem@davemloft.net>
References: <1480829260-4590-1-git-send-email-bianpan201603@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, bianpan2016@163.com
To: bianpan201603@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49252 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751563AbcLETx3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 14:53:29 -0500
In-Reply-To: <1480829260-4590-1-git-send-email-bianpan201603@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pan Bian <bianpan201603@163.com>
Date: Sun,  4 Dec 2016 13:27:40 +0800

> From: Pan Bian <bianpan2016@163.com>
> 
> When the calls to kzalloc() fail, the value of return variable ret may
> be 0. 0 means success in this context. This patch fixes the bug,
> assigning "-ENOMEM" to ret before calling kzalloc().
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188971
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Applied.
