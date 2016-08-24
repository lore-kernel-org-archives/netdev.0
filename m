From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: rtnetlink: Don't export empty
 RTAX_FEATURES
Date: Tue, 23 Aug 2016 17:09:43 -0700 (PDT)
Message-ID: <20160823.170943.937188622813462673.davem@davemloft.net>
References: <1471950871-9112-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55955 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755378AbcHXAJo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 20:09:44 -0400
In-Reply-To: <1471950871-9112-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Tue, 23 Aug 2016 13:14:31 +0200

> Since the features bit field has bits for internal only use as well, it
> may happen that the kernel exports RTAX_FEATURES attribute with zero
> value which is pointless.
> 
> Fix this by making sure the attribute is added only if the exported
> value is non-zero.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied.
