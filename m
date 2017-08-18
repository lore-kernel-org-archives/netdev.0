From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [oss-drivers] [PATCH] nfp: fix infinite loop on umapping
 cleanup
Date: Fri, 18 Aug 2017 07:32:34 -0700
Message-ID: <20170818073234.3f4c5e56@cakuba.netronome.com>
References: <20170818111150.13716-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Horman <simon.horman@netronome.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        oss-drivers@netronome.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:38369 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750984AbdHROch (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 10:32:37 -0400
Received: by mail-pg0-f41.google.com with SMTP id t80so37983467pgb.5
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 07:32:37 -0700 (PDT)
In-Reply-To: <20170818111150.13716-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Aug 2017 12:11:50 +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The while loop that performs the dma page unmapping never decrements
> index counter f and hence loops forever. Fix this with a pre-decrement
> on f.
> 
> Detected by CoverityScan, CID#1357309 ("Infinite loop")
> 
> Fixes: 4c3523623dc0 ("net: add driver for Netronome NFP4000/NFP6000 NIC VFs")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Thanks!
