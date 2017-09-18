From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: use explicit size of struct tcmsg, remove
 need to declare tcm
Date: Mon, 18 Sep 2017 16:52:46 -0700 (PDT)
Message-ID: <20170918.165246.1776895667963317474.davem@davemloft.net>
References: <20170918114038.29741-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170918114038.29741-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Mon, 18 Sep 2017 12:40:38 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Pointer tcm is being initialized and is never read, it is only being used
> to determine the size of struct tcmsg.  Clean this up by removing
> variable tcm and explicitly using the sizeof struct tcmsg rather than *tcm.
> Cleans up clang warning:
> 
> warning: Value stored to 'tcm' during its initialization is never read
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied to net-next.
