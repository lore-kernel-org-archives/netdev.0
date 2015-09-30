From: Arun Parameswaran <aparames@broadcom.com>
Subject: Re: [PATCH 4/4] net: phy: Broadcom Cygnus internal Etherent PHY driver
Date: Wed, 30 Sep 2015 14:43:05 -0700
Message-ID: <560C5769.4070607@broadcom.com>
References: <1443645163-2822-1-git-send-email-arunp@broadcom.com> <1443645163-2822-5-git-send-email-arunp@broadcom.com> <560C5633.5080203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	bcm-kernel-feedback-list <bcm-kernel-feedback-list@broadcom.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Arun Parameswaran <arunp@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <560C5633.5080203@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 15-09-30 02:37 PM, Florian Fainelli wrote:
> On 30/09/15 13:32, Arun Parameswaran wrote:
>> Add support for the Broadcom Cygnus SoCs internal PHY's.
>> The PHYs are 1000M/100M/10M capable with support for 'EEE'
>> and 'APD' (Auto Power Down).
>>
>> This driver supports the following Broadcom Cygnus SoCs:
>>  - BCM583XX (BCM58300, BCM58302, BCM58303, BCM58305)
>>  - BCM113XX (BCM11300, BCM11320, BCM11350, BCM11360)
>>
>> The PHY's on these SoC's require some workarounds for
>> stable operation, both during configuration time and
>> during suspend/resume. This driver handles the
>> application of the workarounds.
>>
>> Signed-off-by: Arun Parameswaran <arunp@broadcom.com>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
>
> Some suggestions if you need to respin this patch series below, sorry
> for not catching that during the internal review:
>
>> +/* Broadcom Cygnus Phy specific registers */
>> +#define MII_BCM_CORE_BASE1E       0x1E /* Core BASE1E register */
>> +#define MII_BCM_EXPB0             0xB0 /* EXPB0 register */
>> +#define MII_BCM_EXPB1             0xB1 /* EXPB1 register */
> These defines could be moved to brcmphy.h for instance, since they are
> shared between all Broadcom PHY drivers AFAICT.

Ok, Will move these and modify the corresponding PHY drivers.

Thanks,
Arun
