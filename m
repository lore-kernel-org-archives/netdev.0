From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qed: add qed_int_sb_init() stub function
Date: Fri, 09 Jun 2017 15:52:09 -0400 (EDT)
Message-ID: <20170609.155209.1236904196625042254.davem@davemloft.net>
References: <20170609103744.3239316-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, Ariel.Elior@cavium.com,
        everest-linux-l2@cavium.com, Manish.Chopra@cavium.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170609103744.3239316-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri,  9 Jun 2017 12:37:35 +0200

> When CONFIG_QED_SRIOV is disabled, we get a build error:
> 
> drivers/net/ethernet/qlogic/qed/qed_int.c: In function 'qed_int_sb_init':
> drivers/net/ethernet/qlogic/qed/qed_int.c:1499:4: error: implicit declaration of function 'qed_vf_set_sb_info'; did you mean 'qed_mcp_get_resc_info'? [-Werror=implicit-function-declaration]
> 
> All the other declarations have a 'static inline' stub as an alternative
> here, so this adds one more for qed_int_sb_init.
> 
> Fixes: 50a207147fce ("qed: Hold a single array for SBs")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thank you.
