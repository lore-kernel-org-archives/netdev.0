From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnxt_en: hide unused
 bnxt_get_max_func_{vnics,rss_ctxs} functions
Date: Wed, 11 Jan 2017 10:51:35 -0500 (EST)
Message-ID: <20170111.105135.364136279090482156.davem@davemloft.net>
References: <20170111143619.502495-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michael.chan@broadcom.com, prashant.sreedharan@broadcom.com,
        sbaddipa@broadcom.com, aduyck@mirantis.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170111143619.502495-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 11 Jan 2017 15:36:09 +0100

> There are lots of #ifdefs in this file, and a recent patch got one
> of them wrong, leading to a harmless warning in some randconfig
> builds:
> 
> ethernet/broadcom/bnxt/bnxt.c:4956:21: error: 'bnxt_get_max_func_vnics' defined but not used [-Werror=unused-function]
> ethernet/broadcom/bnxt/bnxt.c:4947:21: error: 'bnxt_get_max_func_rss_ctxs' defined but not used [-Werror=unused-function]
> 
> Ideally we'd just remove all of them and use 'if (IS_ENABLED())'
> checks instead, which don't have this problem, but for now, I'm
> adding one more #ifdef to shut up the new warning.
> 
> Fixes: 8079e8f107bf ("bnxt_en: Refactor code that determines RFS capability.")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Michael Chan has a fix for this coming my way.
