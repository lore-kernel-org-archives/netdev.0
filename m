From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] net: ieee802154: fix potential null pointer dereference
Date: Tue, 23 May 2017 13:28:53 -0500
Message-ID: <20170523132853.Horde.5IEI9rXUtGVpkMBU_IJgXpJ@gator4166.hostgator.com>
References: <20170523181147.GA32714@embeddedgus>
 <1B82BF85-7AA5-4A52-B0A8-7336DE963567@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: Harry Morris <h.morris@cascoda.com>, linuxdev@cascoda.com,
        Alexander Aring <aar@pengutronix.de>,
        Stefan Schmidt <stefan@osg.samsung.com>,
        linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1B82BF85-7AA5-4A52-B0A8-7336DE963567@holtmann.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcel,

Quoting Marcel Holtmann <marcel@holtmann.org>:

> Hi Gustavo,
>
>> Null check at line 918: if (!spi) {, implies spi might be NULL.
>> Function spi_get_drvdata() dereference pointer spi.
>> Move pointer priv assignment after the null check.
>>
>> Addresses-Coverity-ID: 1408888
>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>> ---
>> drivers/net/ieee802154/ca8210.c | 3 ++-
>> 1 file changed, 2 insertions(+), 1 deletion(-)
>
> patch has been applied to bluetooth-next tree.
>

Awesome :)

Thanks
--
Gustavo A. R. Silva
