From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH] mlxsw: spectrum: mark symbols static where possible
Date: Sun, 18 Sep 2016 12:10:08 +0300
Message-ID: <20160918091008.GA22506@splinter>
References: <1474187987-12958-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@mellanox.com, idosch@mellanox.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, arnd@arndb.de, xie.baoyou@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:48290 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754575AbcIRJKL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 05:10:11 -0400
Content-Disposition: inline
In-Reply-To: <1474187987-12958-1-git-send-email-baoyou.xie@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sun, Sep 18, 2016 at 04:39:47PM +0800, Baoyou Xie wrote:
> We get 3 warnings when building kernel with W=1:
> drivers/net/ethernet/mellanox/mlxsw/spectrum.c:251:29: warning: no previous prototype for 'mlxsw_sp_span_entry_find' [-Wmissing-prototypes]
> drivers/net/ethernet/mellanox/mlxsw/spectrum.c:265:29: warning: no previous prototype for 'mlxsw_sp_span_entry_get' [-Wmissing-prototypes]
> drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c:1749:6: warning: no previous prototype for 'mlxsw_sp_fib_entry_put' [-Wmissing-prototypes]
> 
> In fact, these functions are only used in the file in which they are
> declared and don't need a declaration, but can be made static.
> so this patch marks these functions with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Thanks for the patch! We already have a patch that fixes sparse warnings
(including these) queued up. See:
https://github.com/jpirko/linux_mlxsw/commit/4800ed89f5da55a42a173d5cf9225d4fbb8a96bd

But since we already have one patch under review we've yet to submit it.
https://patchwork.ozlabs.org/patch/670846/

Do you mind dropping this and instead let our patch (with the rest of
the fixes) go through?

Thanks, Ido.
