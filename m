From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] geneve: Get rid of is_all_zero(),
 streamline is_tnl_info_zero()
Date: Sun, 22 Oct 2017 02:43:17 +0100 (WEST)
Message-ID: <20171022.024317.2135335081524620628.davem@davemloft.net>
References: <2f3e906b339869a22c9b7c438c8b854c4bfb885b.1508485663.git.sbrivio@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@ovn.org
To: sbrivio@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57314 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932295AbdJVBnU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 21:43:20 -0400
In-Reply-To: <2f3e906b339869a22c9b7c438c8b854c4bfb885b.1508485663.git.sbrivio@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefano Brivio <sbrivio@redhat.com>
Date: Fri, 20 Oct 2017 13:31:36 +0200

> No need to re-invent memchr_inv() with !is_all_zero(). While at
> it, replace conditional and return clauses with a single return
> clause in is_tnl_info_zero().
> 
> Signed-off-by: Stefano Brivio <sbrivio@redhat.com>

Applied.
