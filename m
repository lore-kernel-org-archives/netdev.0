From: Yijing Wang <wangyijing@huawei.com>
Subject: Re: [PATCH] tg3: remove redundant pm init code
Date: Mon, 3 Jun 2013 15:15:56 +0800
Message-ID: <51AC42AC.9000606@huawei.com>
References: <1369818032-36272-1-git-send-email-wangyijing@huawei.com> <20130603.001301.239203578028894121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <nsujir@broadcom.com>, <mchan@broadcom.com>,
	<linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <guohanjun@huawei.com>,
	<liuj97@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20130603.001301.239203578028894121.davem@davemloft.net>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013/6/3 15:13, David Miller wrote:
> From: Yijing Wang <wangyijing@huawei.com>
> Date: Wed, 29 May 2013 17:00:32 +0800
>=20
>> Pci_enable_device() will set device pm state to D0, so
>> it's no need to do it again in tg3_init_one().
>>
>> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
>=20
> This patch introduces a warning:
>=20
> drivers/net/ethernet/broadcom/tg3.c: In function =A1tg3_init_one=A2:
> drivers/net/ethernet/broadcom/tg3.c:17231:13: warning: =A1pm_cap=A2 m=
ay be used uninitialized in this function [-Wuninitialized]
>=20
Sorry, I will update it and resend soon.

Thanks!
Yijing.

--=20
Thanks!
Yijing
