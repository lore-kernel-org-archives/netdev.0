From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] l2tp: check ps->sock before running
 pppol2tp_session_ioctl()
Date: Sat, 14 Oct 2017 18:39:29 -0700 (PDT)
Message-ID: <20171014.183929.1810886243588964625.davem@davemloft.net>
References: <520e39809f7ca7d8b38282e3a6bf0bbf93219541.1507915312.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com, tparkin@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38312 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751237AbdJOBja (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 21:39:30 -0400
In-Reply-To: <520e39809f7ca7d8b38282e3a6bf0bbf93219541.1507915312.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Fri, 13 Oct 2017 19:22:35 +0200

> When pppol2tp_session_ioctl() is called by pppol2tp_tunnel_ioctl(),
> the session may be unconnected. That is, it was created by
> pppol2tp_session_create() and hasn't been connected with
> pppol2tp_connect(). In this case, ps->sock is NULL, so we need to check
> for this case in order to avoid dereferencing a NULL pointer.
> 
> Fixes: 309795f4bec2 ("l2tp: Add netlink control API for L2TP")
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied and queued up for -stable, thanks.
