From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] skbedit: allow the user to specify bitmask for mark
Date: Thu, 27 Oct 2016 16:09:00 -0400 (EDT)
Message-ID: <20161027.160900.97747790865479168.davem@davemloft.net>
References: <20140724.180708.1613882522982264262.davem@davemloft.net>
        <20161024123257.18228-1-a@unstable.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, eric.dumazet@gmail.com,
        sergei.shtylyov@cogentembedded.com, cwang@twopensource.com,
        antonio@open-mesh.com
To: a@unstable.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33436 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932887AbcJ0UJD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 16:09:03 -0400
In-Reply-To: <20161024123257.18228-1-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <a@unstable.cc>
Date: Mon, 24 Oct 2016 20:32:57 +0800

> The user may want to use only some bits of the skb mark in
> his skbedit rules because the remaining part might be used by
> something else.
> 
> Introduce the "mask" parameter to the skbedit actor in order
> to implement such functionality.
> 
> When the mask is specified, only those bits selected by the
> latter are altered really changed by the actor, while the
> rest is left untouched.
> 
> Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied, thanks.
