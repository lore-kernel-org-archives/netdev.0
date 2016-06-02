From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH] rds: fix an infoleak in rds_inc_info_copy
Date: Thu, 2 Jun 2016 08:25:00 -0700
Message-ID: <1a923a3b-9452-5c3f-ed3b-fbe585d91558@oracle.com>
References: <1464855080-29671-1-git-send-email-kjlu@gatech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu,
	csong84@gatech.edu, Kangjie Lu <kjlu@gatech.edu>
To: Kangjie Lu <kangjielu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464855080-29671-1-git-send-email-kjlu@gatech.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/2/2016 1:11 AM, Kangjie Lu wrote:
> The last field "flags" of object "minfo" is not initialized.
> Copying this object out may leak kernel stack data.
> Assign 0 to it to avoid leak.
>
> Signed-off-by: Kangjie Lu <kjlu@gatech.edu>
> ---
>  net/rds/recv.c | 2 ++
>  1 file changed, 2 insertions(+)
>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
