From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: mark symbols static where possible
Date: Mon, 19 Sep 2016 21:56:01 -0400 (EDT)
Message-ID: <20160919.215601.1083848074956442188.davem@davemloft.net>
References: <1474187729-25326-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
        sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, xie.baoyou@zte.com.cn
To: baoyou.xie@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474187729-25326-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Sun, 18 Sep 2016 16:35:29 +0800

> We get 4 warnings when building kernel with W=1:
> drivers/net/ethernet/emulex/benet/be_main.c:4368:6: warning: no previous prototype for 'be_calculate_pf_pool_rss_tables' [-Wmissing-prototypes]
> drivers/net/ethernet/emulex/benet/be_cmds.c:4385:5: warning: no previous prototype for 'be_get_nic_pf_num_list' [-Wmissing-prototypes]
> drivers/net/ethernet/emulex/benet/be_cmds.c:4537:6: warning: no previous prototype for 'be_reset_nic_desc' [-Wmissing-prototypes]
> drivers/net/ethernet/emulex/benet/be_cmds.c:4910:5: warning: no previous prototype for '__be_cmd_set_logical_link_config' [-Wmissing-prototypes]
> 
> In fact, these functions are only used in the file in which they are
> declared and don't need a declaration, but can be made static.
> so this patch marks these functions with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Applied.
