From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] dlci: validate the net device in dlci_del()
Date: Wed, 26 Jun 2013 15:46:31 -0700 (PDT)
Message-ID: <20130626.154631.1134375305331643368.davem@davemloft.net>
References: <51CA9872.5050700@huawei.com>
	<51CA98EE.4050801@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	trinity@vger.kernel.org, lijinyue@huawei.com
To: lizefan@huawei.com
Return-path: <trinity-owner@vger.kernel.org>
In-Reply-To: <51CA98EE.4050801@huawei.com>
Sender: trinity-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Li Zefan <lizefan@huawei.com>
Date: Wed, 26 Jun 2013 15:31:58 +0800

> We triggered an oops while running trinity with 3.4 kernel:
> 
> BUG: unable to handle kernel paging request at 0000000100000d07
> IP: [<ffffffffa0109738>] dlci_ioctl+0xd8/0x2d4 [dlci]
> PGD 640c0d067 PUD 0
> Oops: 0000 [#1] PREEMPT SMP
> CPU 3
> ...
> Pid: 7302, comm: trinity-child3 Not tainted 3.4.24.09+ 40 Huawei Technologies Co., Ltd. Tecal RH2285          /BC11BTSA
> RIP: 0010:[<ffffffffa0109738>]  [<ffffffffa0109738>] dlci_ioctl+0xd8/0x2d4 [dlci]
> ...
> Call Trace:
>   [<ffffffff8137c5c3>] sock_ioctl+0x153/0x280
>   [<ffffffff81195494>] do_vfs_ioctl+0xa4/0x5e0
>   [<ffffffff8118354a>] ? fget_light+0x3ea/0x490
>   [<ffffffff81195a1f>] sys_ioctl+0x4f/0x80
>   [<ffffffff81478b69>] system_call_fastpath+0x16/0x1b
> ...
> 
> It's because the net device is not a dlci device.
> 
> Reported-by: Li Jinyue <lijinyue@huawei.com>
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Applied and queued up for -stable.
