From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] lwtunnel: Add destroy state operation
Date: Fri, 14 Oct 2016 11:15:56 -0400 (EDT)
Message-ID: <20161014.111556.1642003912363855762.davem@davemloft.net>
References: <20161014005743.288956-1-tom@herbertland.com>
        <20161014005743.288956-2-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48200 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753125AbcJNPP6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 11:15:58 -0400
In-Reply-To: <20161014005743.288956-2-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 13 Oct 2016 17:57:42 -0700

> @@ -130,6 +130,19 @@ int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
>  }
>  EXPORT_SYMBOL(lwtunnel_build_state);
>  
> +void  lwtstate_free(struct lwtunnel_state *lws)

There should only be one space between "void" and "lwstate_free".
