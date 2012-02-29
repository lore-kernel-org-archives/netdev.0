From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add QCA alx Ethernet driver
Date: Tue, 28 Feb 2012 22:32:58 -0500 (EST)
Message-ID: <20120228.223258.2261979237568571219.davem@davemloft.net>
References: <157393863283F442885425D2C4542856194154FC@nasanexd02a.na.qualcomm.com>
	<20120228.212857.797446903975232476.davem@davemloft.net>
	<157393863283F442885425D2C454285619415561@nasanexd02a.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rodrigue@qca.qualcomm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, qca-linux-team@qualcomm.com,
	nic-devel@qualcomm.com, kgiori@qca.qualcomm.com,
	chris.snook@gmail.com, mathieu@qca.qualcomm.com, bryanh@quicinc.com
To: xiong@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <157393863283F442885425D2C454285619415561@nasanexd02a.na.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Date: Wed, 29 Feb 2012 03:11:14 +0000

> We understand your concern.  To support the new chipset, do you
> think it's reasonable to upstream it as a new driver, not a
> replacement ?

It depends upon how similar the chips are.

To be honest tg3, as one example, supports quite a large array of
different pieces of hardware that use the same logical core.

So that would be my litmus test about how different a chip needs
to be to deserve an entirely new driver.

I strongly suggest you try to get atl1c working properly.
