From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net-next] l2tp: Avoid schedule while atomic in exit_net
Date: Wed, 22 Feb 2017 13:09:26 +0100
Message-ID: <20170222120926.ssdoxnnrudfzusay@alphalink.fr>
References: <20170222015949.18641-1-ridge.kennedy@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ridge Kennedy <ridge.kennedy@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:48188 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754170AbdBVMJh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 07:09:37 -0500
Content-Disposition: inline
In-Reply-To: <20170222015949.18641-1-ridge.kennedy@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 22, 2017 at 02:59:49PM +1300, Ridge Kennedy wrote:
> While destroying a network namespace that contains a L2TP tunnel a
> "BUG: scheduling while atomic" can be observed.

> To fix this, move the call to l2tp_tunnel_closeall() out of the RCU
> critical section, and instead call it from l2tp_tunnel_del_work(), which
> is running from the l2tp_wq workqueue.
> 
Looks good, though this should be for net, not net-next.

Acked-by: Guillaume Nault <g.nault@alphalink.fr>
