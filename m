From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] gre: add collect_md mode for ERSPAN
 tunnel
Date: Mon, 28 Aug 2017 15:06:44 -0700 (PDT)
Message-ID: <20170828.150644.2144946919411514968.davem@davemloft.net>
References: <1503678089-27131-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: u9012063@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49448 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750841AbdH1WGp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 18:06:45 -0400
In-Reply-To: <1503678089-27131-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Tu <u9012063@gmail.com>
Date: Fri, 25 Aug 2017 09:21:26 -0700

> This patch series provide collect_md mode for ERSPAN tunnel.  The fist patch
> refactors the existing gre_fb_xmit function by exacting the route cache
> portion into a new function called prepare_fb_xmit.  The second patch
> introduces the collect_md mode for ERSPAN tunnel, by calling the
> prepare_fb_xmit function and adding ERSPAN specific logic.  The final patch
> adds the test case using bpf_skb_{set,get}_tunnel_{key,opt}.

Series applied, thanks William.
