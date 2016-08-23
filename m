From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: Re: [PATCH] cxgb4: fix invalid checks in alloc_uld_rxqs
Date: Tue, 23 Aug 2016 13:16:06 +0530
Message-ID: <20160823074554.GA19307@hari-Latitude-E5550>
References: <1471932979-17864-1-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "open list:CXGB4 ETHERNET DRIVER (CXGB4)" <netdev@vger.kernel.org>,
        Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
        Marek Szyprowski <m.szyprowski@samsung.com>,
        open list <linux-kernel@vger.kernel.org>
To: Andrzej Hajda <a.hajda@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1471932979-17864-1-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, August 08/23/16, 2016 at 08:16:19 +0200, Andrzej Hajda wrote:
> Local variable msi_idx defined as unsigned int is always >= 0, thus both
> 'if' checks are always true. On the other side presence of USING_MSIX flag
> suggests the checks should not be trivially true.
> The simplest solution is to replace incorrect checks with direct testing
> of adap->flags and remove spare variables.
> 
> The problem has been detected using semantic patch
> scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci
> 

The correct fix is to have local variable 'msi_idx' as int instead of unsigned
int. Thanks for reporting the issue. Do you want me to send a V2?

Thanks,
Hari
