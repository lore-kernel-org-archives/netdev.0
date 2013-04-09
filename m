From: Li Zefan <lizefan@huawei.com>
Subject: Re: [PATCH 1/2] netprio_cgroup: remove task_struct parameter from
 sock_update_netprio()
Date: Tue, 9 Apr 2013 14:02:02 +0800
Message-ID: <5163AEDA.6020805@huawei.com>
References: <5163AE92.7010302@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5163AE92.7010302@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry, please ignore it. I sent it in the wrong order...

On 2013/4/9 14:00, Li Zefan wrote:
> The callers always pass current to sock_update_netprio().
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>
> ---
>  include/net/netprio_cgroup.h | 4 ++--
>  net/core/scm.c               | 2 +-
>  net/core/sock.c              | 6 +++---
>  3 files changed, 6 insertions(+), 6 deletions(-)
