From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] bpf: fix return in bpf_skb_adjust_net
Date: Thu, 13 Jul 2017 11:20:58 +0200
Message-ID: <59673B7A.2080606@iogearbox.net>
References: <1499927278-175876-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Kefeng Wang <wangkefeng.wang@huawei.com>,
        Alexei Starovoitov <ast@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499927278-175876-1-git-send-email-wangkefeng.wang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/13/2017 08:27 AM, Kefeng Wang wrote:
> The bpf_skb_adjust_net() ignores the return value of bpf_skb_net_shrink/grow,
> and always return 0, fix it by return 'ret'.
>
> Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>

Sigh, yep of course. Thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
