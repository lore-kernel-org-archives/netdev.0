From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] net: hns: avoid null pointer dereference
Date: Mon, 23 May 2016 13:55:10 -0700 (PDT)
Message-ID: <20160523.135510.281587414446265876.davem@davemloft.net>
References: <063D6719AE5E284EB5DD2968C1650D6D5F4C22D9@AcuExch.aculab.com>
	<1463685655-3277-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@aculab.com, Yisen.Zhuang@huawei.com,
	yankejian@huawei.com, lisheng011@huawei.com, andrew@lunn.ch,
	salil.mehta@huawei.com, ivecera@redhat.com, chenny.xu@huawei.com,
	huangdaode@hisilicon.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xypron.glpk@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463685655-3277-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Thu, 19 May 2016 21:20:55 +0200

> In the statement
>   assert(priv || priv->ae_handle);
> the right side of || is only evaluated if priv is null.
> 
> v2:
> 	As suggested by David Leight and David Miller the assert
> 	statements are removed.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Applied.
