From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_nv: fix division by zero in tcpnv_acked()
Date: Thu, 02 Nov 2017 16:17:55 +0900 (KST)
Message-ID: <20171102.161755.1469652396797608567.davem@davemloft.net>
References: <150954313588.153848.10192893966808917578.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brakmo@fb.com, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org
To: khlebnikov@yandex-team.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <150954313588.153848.10192893966808917578.stgit@buzz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Wed, 01 Nov 2017 16:32:15 +0300

> Average RTT could become zero. This happened in real life at least twice.
> This patch treats zero as 1us.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Applied and queued up for -stable, thank you.

Indeed, as others have mentioned, a cheaper divide should be used
but that is a separate issue from this fix and therefore should be
done in a separate patch.

Thanks again.
