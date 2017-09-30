From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net] RDS: IB: Limit the scope of has_fr/has_fmr variables
Date: Fri, 29 Sep 2017 18:38:00 -0700
Message-ID: <ca85fffb-87b6-4e4d-b23d-1f80caa36087@oracle.com>
References: <1506734030-15205-1-git-send-email-avinash.repaka@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Avinash Repaka <avinash.repaka@oracle.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506734030-15205-1-git-send-email-avinash.repaka@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/29/2017 6:13 PM, Avinash Repaka wrote:
> This patch fixes the scope of has_fr and has_fmr variables as they are
> needed only in rds_ib_add_one().
> 
> Signed-off-by: Avinash Repaka <avinash.repaka@oracle.com>
> ---
Indeed the final merge version actually didn't need
those across files. Change looks good to me. Thanks !!

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
