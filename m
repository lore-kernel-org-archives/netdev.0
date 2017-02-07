From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] read vnet_hdr_sz once
Date: Mon, 06 Feb 2017 22:48:32 -0500 (EST)
Message-ID: <20170206.224832.368324796028951375.davem@davemloft.net>
References: <20170203232049.38982-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56886 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdBGDsh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 22:48:37 -0500
In-Reply-To: <20170203232049.38982-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Fri,  3 Feb 2017 18:20:47 -0500

> Tuntap devices allow concurrent use and update of field vnet_hdr_sz.
> Read the field once to avoid TOCTOU.

Series applied and queued up for -stable, thanks.
