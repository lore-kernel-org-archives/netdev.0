From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bpf: fix return in bpf_skb_adjust_net
Date: Thu, 13 Jul 2017 09:19:37 -0700 (PDT)
Message-ID: <20170713.091937.315484447447541551.davem@davemloft.net>
References: <1499927278-175876-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: wangkefeng.wang@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499927278-175876-1-git-send-email-wangkefeng.wang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kefeng Wang <wangkefeng.wang@huawei.com>
Date: Thu, 13 Jul 2017 14:27:58 +0800

> The bpf_skb_adjust_net() ignores the return value of bpf_skb_net_shrink/grow,
> and always return 0, fix it by return 'ret'.
> 
> Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>

Applied, thanks.
