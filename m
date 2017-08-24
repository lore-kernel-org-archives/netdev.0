From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3 v3] net: tipc: constify genl_ops
Date: Wed, 23 Aug 2017 22:32:12 -0700 (PDT)
Message-ID: <20170823.223212.2236765862347036476.davem@davemloft.net>
References: <1503485540-22113-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
        kvalo@codeaurora.org, jon.maloy@ericsson.com,
        ying.xue@windriver.com, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: arvind.yadav.cs@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503485540-22113-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Wed, 23 Aug 2017 16:22:20 +0530

> genl_ops are not supposed to change at runtime. All functions
> working with genl_ops provided by <net/genetlink.h> work with
> const genl_ops. So mark the non-const structs as const.
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>

Applied.
