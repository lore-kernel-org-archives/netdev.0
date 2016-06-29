From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [RFC 1/7] net: ethernet: bgmac: change bgmac_* prints to dev_* prints
Date: Wed, 29 Jun 2016 16:10:56 -0400
Message-ID: <CAC3K-4o4bTRh2EsWCrESCjKHMb7A7eY5PhhqF+m8PALESWxOLg@mail.gmail.com>
References: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
 <1467142484-11161-2-git-send-email-jon.mason@broadcom.com> <1467143038.24287.50.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467143038.24287.50.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 28, 2016 at 3:43 PM, Joe Perches <joe@perches.com> wrote:
> On Tue, 2016-06-28 at 15:34 -0400, Jon Mason wrote:
>> The bgmac_* print wrappers call dev_* prints with the dev pointer from
>> the bcma core.  In anticipation of removing the bcma requirement for
>> this driver, these must be changed to not reference that struct.  So,
>> simply change all of the bgmac_* prints to their dev_* counterparts.  In
>> some cases netdev_* prints are more appropriate, so change those as
>> well.
>
> Thanks, but...
>
>> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
> []
>> @@ -1515,7 +1516,7 @@ static void bgmac_get_drvinfo(struct net_device *net_dev,
>>                             struct ethtool_drvinfo *info)
>>  {
>>       strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
>> -     strlcpy(info->bus_info, "BCMA", sizeof(info->bus_info));
>> +     strlcpy(info->bus_info, "AXI", sizeof(info->bus_info));
>>  }
>
> Unrelated change?

This is a needed change, but unrelated to this patch.  I'll move it to
the 5/7 patch, where it more logically fits.

Thanks,
Jon

>
