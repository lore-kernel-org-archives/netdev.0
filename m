From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] nfp: fix infinite loop on umapping cleanup
Date: Fri, 18 Aug 2017 10:29:19 -0700 (PDT)
Message-ID: <20170818.102919.1311901104192299250.davem@davemloft.net>
References: <20170818111150.13716-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon.horman@netronome.com, daniel@iogearbox.net,
        oss-drivers@netronome.com, netdev@vger.kernel.org,
        jakub.kicinski@netronome.com, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170818111150.13716-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Fri, 18 Aug 2017 12:11:50 +0100

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

Applied and queued up for -stable.
