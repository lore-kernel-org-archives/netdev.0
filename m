From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net v2] rds: Fix incorrect statistics counting
Date: Wed, 6 Sep 2017 09:48:46 -0700
Message-ID: <8260b33b-504b-8b7e-44d0-b8699f33ab74@oracle.com>
References: <20170906163551.20387-1-Haakon.Bugge@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-kernel@vger.kernel.org,
        knut.omang@oracle.com
To: =?UTF-8?Q?H=c3=a5kon_Bugge?= <Haakon.Bugge@oracle.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170906163551.20387-1-Haakon.Bugge@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/6/2017 9:35 AM, Håkon Bugge wrote:
> In rds_send_xmit() there is logic to batch the sends. However, if
> another thread has acquired the lock and has incremented the send_gen,
> it is considered a race and we yield. The code incrementing the
> s_send_lock_queue_raced statistics counter did not count this event
> correctly.
> 
> This commit counts the race condition correctly.
> 
> Changes from v1:
> - Removed check for *someone_on_xmit()*
> - Fixed incorrect indentation
> 
> Signed-off-by: Håkon Bugge <haakon.bugge@oracle.com>
> Reviewed-by: Knut Omang <knut.omang@oracle.com>
> ---

Thanks for the update.
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
