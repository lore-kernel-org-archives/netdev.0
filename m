From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 3/3] net: rsi: netlink: constify genl_ops
Date: Wed, 23 Aug 2017 13:02:49 +0300
Message-ID: <87378iy52u.fsf@kamboji.qca.qualcomm.com>
References: <1503482375-19983-1-git-send-email-arvind.yadav.cs@gmail.com>
        <1503482375-19983-4-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, Larry.Finger@lwfinger.net,
        chaoming_li@realsil.com.cn, jon.maloy@ericsson.com,
        ying.xue@windriver.com, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503482375-19983-4-git-send-email-arvind.yadav.cs@gmail.com>
        (Arvind Yadav's message of "Wed, 23 Aug 2017 15:29:35 +0530")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arvind Yadav <arvind.yadav.cs@gmail.com> writes:

> genl_ops are not supposed to change at runtime. All functions
> working with genl_ops provided by <net/genetlink.h> work with
> const genl_ops. So mark the non-const structs as const.
>
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
> ---
>  net/tipc/netlink_compat.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Using the prefix "rsi:" looks wrong for this patch.

-- 
Kalle Valo
