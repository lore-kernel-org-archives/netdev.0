From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] openvswitch: add ct_clear action
Date: Mon, 09 Oct 2017 20:52:58 -0700 (PDT)
Message-ID: <20171009.205258.2217031283181986144.davem@davemloft.net>
References: <20171006164426.9752-1-e@erig.me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, pshelar@nicira.com
To: e@erig.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34496 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755048AbdJJDw6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 23:52:58 -0400
In-Reply-To: <20171006164426.9752-1-e@erig.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Garver <e@erig.me>
Date: Fri,  6 Oct 2017 12:44:26 -0400

> This adds a ct_clear action for clearing conntrack state. ct_clear is
> currently implemented in OVS userspace, but is not backed by an action
> in the kernel datapath. This is useful for flows that may modify a
> packet tuple after a ct lookup has already occurred.
> 
> Signed-off-by: Eric Garver <e@erig.me>

Pravin et al., this needs your review.

Thanks.
