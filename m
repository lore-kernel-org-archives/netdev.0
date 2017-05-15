From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] qed: Fix uninitialized data in aRFS
 infrastructure
Date: Mon, 15 May 2017 14:39:13 -0400 (EDT)
Message-ID: <20170515.143913.1695026862760668885.davem@davemloft.net>
References: <1494753683-3429-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38352 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932948AbdEOSjO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 14:39:14 -0400
In-Reply-To: <1494753683-3429-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Sun, 14 May 2017 12:21:23 +0300

> Current memset is using incorrect type of variable, causing the
> upper-half of the strucutre to be left uninitialized and causing:
> 
>   ethernet/qlogic/qed/qed_init_fw_funcs.c: In function 'qed_set_rfs_mode_disable':
>   ethernet/qlogic/qed/qed_init_fw_funcs.c:993:3: error: '*((void *)&ramline+4)' is used uninitialized in this function [-Werror=uninitialized]
> 
> Fixes: d51e4af5c209 ("qed: aRFS infrastructure support")
> Reported-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>

Applied, thank you.
