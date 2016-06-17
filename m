From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] net: qlcnic: don't set unused function argument
Date: Thu, 16 Jun 2016 17:33:26 -0700 (PDT)
Message-ID: <20160616.173326.1960266414450397084.davem@davemloft.net>
References: <20160616113831.4108439-1-arnd@arndb.de>
	<20160616113831.4108439-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Dept-GELinuxNICDev@qlogic.com, rajesh.borundia@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160616113831.4108439-2-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 16 Jun 2016 13:38:22 +0200

> We get a warning for qlcnic_83xx_get_mac_address when building with
> "make W=1":
> 
> drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c: In function 'qlcnic_83xx_get_mac_address':
> drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c:2156:8: error: parameter 'function' set but not used [-Werror=unused-but-set-parameter]
> 
> Clearly this is harmless, but there is also no point for setting
> the variable, so we can simply remove the assignment.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied to net-next.
