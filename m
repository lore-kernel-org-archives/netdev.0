From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: l2tp: mark expected switch fall-through
Date: Thu, 19 Oct 2017 13:34:10 +0100 (WEST)
Message-ID: <20171019.133410.1724417856668534994.davem@davemloft.net>
References: <20171017224253.GA5877@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49198 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752089AbdJSMeU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 08:34:20 -0400
In-Reply-To: <20171017224253.GA5877@embeddedor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Tue, 17 Oct 2017 17:42:53 -0500

> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Notice that in this particular case I replaced the "NOBREAK" comment with
> a "fall through" comment, which is what GCC is expecting to find.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied to net-next.
