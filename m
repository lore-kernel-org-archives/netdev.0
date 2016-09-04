From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] openvswitch: Free tmpl with tmpl_free.
Date: Sun, 04 Sep 2016 11:38:19 -0700 (PDT)
Message-ID: <20160904.113819.252288220140300497.davem@davemloft.net>
References: <20160902010147.16439-1-joe@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@kernel.org
To: joe@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37184 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753671AbcIDSi3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2016 14:38:29 -0400
In-Reply-To: <20160902010147.16439-1-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@ovn.org>
Date: Thu,  1 Sep 2016 18:01:47 -0700

> When an error occurs during conntrack template creation as part of
> actions validation, we need to free the template. Previously we've been
> using nf_ct_put() to do this, but nf_ct_tmpl_free() is more appropriate.
> 
> Signed-off-by: Joe Stringer <joe@ovn.org>

Applied, thanks.
