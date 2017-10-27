From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: faraday: ftmac100: Use BUG_ON instead of if
 condition followed by BUG.
Date: Fri, 27 Oct 2017 23:56:15 +0900 (KST)
Message-ID: <20171027.235615.1230077708366736999.davem@davemloft.net>
References: <20171026122745.GA9510@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50918 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752037AbdJ0O4S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 10:56:18 -0400
In-Reply-To: <20171026122745.GA9510@embeddedor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Thu, 26 Oct 2017 07:27:45 -0500

> Notice that in this particular case unlikely() is already being called
> inside BUG_ON macro.
> 
> This issue was detected with the help of Coccinelle.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied.
