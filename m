From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] phy/at8031: enable at8031 to work on interrupt mode
Date: Fri, 28 Mar 2014 21:09:02 +0300
Message-ID: <5335BABE.80007@cogentembedded.com>
References: <1395901116-16034-1-git-send-email-B45475@freescale.com> <53341101.9000404@cogentembedded.com> <0ca1e7910cd247c4aebe4cbd48a633cb@BLUPR03MB341.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"mugunthanvnm@ti.com" <mugunthanvnm@ti.com>,
	"zonque@gmail.com" <zonque@gmail.com>,
	"helmut.schaa@googlemail.com" <helmut.schaa@googlemail.com>,
	Xiaobo Xie <X.Xie@freescale.com>
To: "qiang.zhao@freescale.com" <qiang.zhao@freescale.com>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Scott Wood <scottwood@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0ca1e7910cd247c4aebe4cbd48a633cb@BLUPR03MB341.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 03/28/2014 10:36 AM, qiang.zhao@freescale.com wrote:

>>> The at8031 can work on polling mode and interrupt mode.
>>> Add ack_interrupt and config intr funcs to enable interrupt mode for
>>> it.

>>> Signed-off-by: Zhao Qiang <B45475@freescale.com>
>>> ---
>>>    drivers/net/phy/at803x.c | 30 ++++++++++++++++++++++++++++++
>>>    1 file changed, 30 insertions(+)

>>> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c index
>>> bc71947..d034ef5 100644
>>> --- a/drivers/net/phy/at803x.c
>>> +++ b/drivers/net/phy/at803x.c
>> [...]
>>> @@ -191,6 +194,31 @@ static int at803x_config_init(struct phy_device
>> *phydev)
>>>    	return 0;
>>>    }
>>>
>>> +static int at803x_ack_interrupt(struct phy_device *phydev) {
>>> +	int err;
>>> +
>>> +	err = phy_read(phydev, AT803X_INSR);

>>      Could make this an initializer...

> Thank you very much. However I have no idea about "make this an initializer".

	int err = phy_read(phydev, AT803X_INSR);

WBR, Sergei
