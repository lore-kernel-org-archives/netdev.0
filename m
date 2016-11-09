From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/2] bpf, mlx4: fix prog refcount in mlx4_en_try_alloc_resources
 error path
Date: Wed, 09 Nov 2016 12:04:19 +0100
Message-ID: <582302B3.9040501@iogearbox.net>
References: <201611091853.HAp072gP%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, Zhiyi Sun <zhiyisun@gmail.com>,
        bblanco@plumgrid.com, Tariq Toukan <tariqt@mellanox.com>,
        Yishai Hadas <yishaih@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        alexei.starovoitov@gmail.com
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201611091853.HAp072gP%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/09/2016 11:58 AM, kbuild test robot wrote:
[...]
> All errors (new ones prefixed by >>):
>
>     drivers/net/ethernet/mellanox/mlx4/en_netdev.c: In function 'mlx4_xdp_set':
>>> drivers/net/ethernet/mellanox/mlx4/en_netdev.c:2752:4: error: implicit declaration of function 'bpf_prog_add_undo' [-Werror=implicit-function-declaration]
>         bpf_prog_add_undo(prog, priv->rx_ring_num - 1);
>         ^~~~~~~~~~~~~~~~~
>     cc1: some warnings being treated as errors

Ahh right, needs an empty variant for !CONFIG_BPF_SYSCALL. I'll fix that up
before sending an official patch.

Thanks,
Daniel
