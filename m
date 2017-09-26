From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net v3] l2tp: fix race condition in l2tp_tunnel_delete
Date: Tue, 26 Sep 2017 16:56:11 +0200
Message-ID: <20170926145611.j6rwrsvq3prt3ryv@alphalink.fr>
References: <d6011f741f7ea38a61006b9f2cde8e544b4d206b.1506432922.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Xin Long <lucien.xin@gmail.com>,
        Tom Parkin <tparkin@katalix.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:55455 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031076AbdIZO4V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 10:56:21 -0400
Content-Disposition: inline
In-Reply-To: <d6011f741f7ea38a61006b9f2cde8e544b4d206b.1506432922.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 04:16:43PM +0200, Sabrina Dubroca wrote:
> Add a dead flag to prevent firing the workqueue twice. Then we can
> remove the check of queue_work's result that was meant to prevent that
> race but doesn't.
> 
Acked-by: Guillaume Nault <g.nault@alphalink.fr>
