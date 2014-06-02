From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: Remove spin_lock call in
 stmmac_get_pauseparam()
Date: Mon, 02 Jun 2014 10:38:34 -0700 (PDT)
Message-ID: <20140602.103834.1994455666478487120.davem@davemloft.net>
References: <1401701450-1203-1-git-send-email-emilgoode@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Wei.Yang@windriver.com, peppe.cavallaro@st.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: emilgoode@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401701450-1203-1-git-send-email-emilgoode@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Emil Goode <emilgoode@gmail.com>
Date: Mon,  2 Jun 2014 11:30:50 +0200

> The following patch removed unnecessary spin_lock/unlock calls
> in ethtool_ops callback functions. In the second and final version
> of the patch one spin_lock call was left behind.
> 
> commit cab6715c3e8029e98b0b5d4056ceda007c0f6380
> Author: Yang Wei <Wei.Yang@windriver.com>
> Date:   Sun May 25 09:53:44 2014 +0800
> 
>     net: driver: stmicro: Remove some useless the lock protection
> 
> This introduced the following sparse warning:
> 
> drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c:424:1: warning:
> 	context imbalance in 'stmmac_get_pauseparam' -
> 	different lock contexts for basic block
> 
> Signed-off-by: Emil Goode <emilgoode@gmail.com>

Good catch, applied, thanks Emil.
