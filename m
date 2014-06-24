From: Amir Vadai <amirv.mellanox@gmail.com>
Subject: Re: [PATCH net 1/3] net/mlx4_en: Don't use irq_affinity_notifier
 to track changes in IRQ affinity map
Date: Tue, 24 Jun 2014 10:51:22 +0300
Message-ID: <53A92DFA.5040302@gmail.com>
References: <1403534518-20898-1-git-send-email-amirv@mellanox.com> <1403534518-20898-2-git-send-email-amirv@mellanox.com>
Reply-To: amirv@mellanox.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:34123 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbaFXHvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 03:51:31 -0400
Received: by mail-we0-f172.google.com with SMTP id u57so8331401wes.17
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 00:51:30 -0700 (PDT)
In-Reply-To: <1403534518-20898-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/23/2014 5:41 PM, Amir Vadai wrote:
> IRQ affinity notifier can only have a single notifier - cpu_rmap
> notifier. Can't use it to track changes in IRQ affinity map.
> Detect IRQ affinity changes by comparing CPU to current IRQ affinity map
> during NAPI poll thread.
> 
> Fixes: 2eacc23 ("net/mlx4_core: Enforce irq affinity changes immediatly")
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Hi,

It seems that this patch will break compilation on s390 architecture.
Please don't pull it - I will do some more work on it and send a V1 of
the patch set.

Amir
