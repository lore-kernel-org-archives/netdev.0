From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net] RDS: IB: Initialize max_items based on underlying
 device attributes
Date: Tue, 3 Oct 2017 18:07:59 -0700
Message-ID: <1292cf1e-bbc7-9ee6-aafc-29d2e5c8befb@oracle.com>
References: <1507078237-32366-1-git-send-email-avinash.repaka@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Avinash Repaka <avinash.repaka@oracle.com>,
        linux-rdma@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507078237-32366-1-git-send-email-avinash.repaka@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Avinash,

On 10/3/2017 5:50 PM, Avinash Repaka wrote:
> Use max_1m_mrs/max_8k_mrs while setting max_items, as the former
> variables are set based on the underlying device attricutes.
> 
s/attricutes/attributes

> Signed-off-by: Avinash Repaka <avinash.repaka@oracle.com>
> ---
>   net/rds/ib_rdma.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> 
This patch is fine but it will be nice if you can collect
these changes in series as you are trying to update the
FRWR support. Like this patch and other cleanup patch
you posted yesterday.

With that log fixed,
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
