From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: hns: avoid null pointer dereference
Date: Thu, 19 May 2016 11:26:07 -0700 (PDT)
Message-ID: <20160519.112607.1614392639969487509.davem@davemloft.net>
References: <1463515275-9836-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yisen.Zhuang@huawei.com, yankejian@huawei.com,
	lisheng011@huawei.com, liguozhu@huawei.com, andrew@lunn.ch,
	salil.mehta@huawei.com, xieqianqian@huawei.com,
	huangdaode@hisilicon.com, chenny.xu@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xypron.glpk@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463515275-9836-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Tue, 17 May 2016 22:01:15 +0200

> In the statement
>   assert(priv || priv->ae_handle);
> the right side of || is only evaluated if priv is null.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

I agree with others that this assert() is pretty useless and should
simply be removed.
