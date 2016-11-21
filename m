From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: zero ca_priv area when switching cc algorithms
Date: Mon, 21 Nov 2016 13:14:23 -0500 (EST)
Message-ID: <20161121.131423.1400416428808695997.davem@davemloft.net>
References: <1479719317-22437-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55522 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752299AbcKUSOZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 13:14:25 -0500
In-Reply-To: <1479719317-22437-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 21 Nov 2016 10:08:37 +0100

> We need to zero out the private data area when application switches
> connection to different algorithm (TCP_CONGESTION setsockopt).
> 
> When congestion ops get assigned at connect time everything is already
> zeroed because sk_alloc uses GFP_ZERO flag.  But in the setsockopt case
> this contains whatever previous cc placed there.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Good catch, applied, thanks Florian.
