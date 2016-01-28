From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] ptp: ixp46x: use helpers for converting ns to timespec
Date: Thu, 28 Jan 2016 10:47:16 +0100
Message-ID: <20160128094716.GA3345@localhost.localdomain>
References: <1453948039-3198-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>, guohanjun@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kefeng Wang <wangkefeng.wang@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1453948039-3198-1-git-send-email-wangkefeng.wang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 28, 2016 at 10:27:19AM +0800, Kefeng Wang wrote:
> Convert the driver to use ns_to_timespec64() and timespec64_to_ns()
> instead of open coding the same logic.
> 
> Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
> ---
>  drivers/ptp/ptp_ixp46x.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)

Acked-by: Richard Cochran <richardcochran@gmail.com>
