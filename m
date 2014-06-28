From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH net v3 2/3] libphy: Add stubs to hook IEEE MMD Register
 reads and writes
Date: Sat, 28 Jun 2014 14:47:04 -0500
Message-ID: <CAOwfj2NJGqp2GF0v8421TVCYnnDLYYRa9oafDULi9pY1wh=wkw@mail.gmail.com>
References: <1403482910-20821-1-git-send-email-vbridgers2013@gmail.com>
	<1403482910-20821-3-git-send-email-vbridgers2013@gmail.com>
	<53A81D96.3040904@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:59660 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbaF1TrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2014 15:47:06 -0400
Received: by mail-wi0-f182.google.com with SMTP id bs8so4271998wib.3
        for <netdev@vger.kernel.org>; Sat, 28 Jun 2014 12:47:04 -0700 (PDT)
In-Reply-To: <53A81D96.3040904@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 23, 2014 at 7:29 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
>
> On 06/23/2014 04:21 AM, Vince Bridgers wrote:
>
>> The Micrel ksz9021 PHY does not support standard IEEE standard MMD
>> extended register access, therefore requires stubs to fail the read
>> register method and do nothing for the write register method when
>> libphy attempts to read and/or configure Energy Efficient Ethernet
>> features in PHYS that do support those features. This problem
>> was observed on an Altera Cyclone V SOC development kit that
>> uses the Synopsys EMAC and the Micrel ksz9021 PHY. This patch
>> was tested on the same board, and Energy Efficient Ethernet is
>> now disabled as expected since the Micrel PHY does not support that
>> feature.
>
>
>> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
>> ---
>> V3: Remove unnecessary returns from void functions.
>> V2: Split libphy and Micrel specific changes into 2 patches
>>      based on review comments
>> ---
>>   drivers/net/phy/micrel.c |   23 ++++++++++++++++++++++-
>>   1 file changed, 22 insertions(+), 1 deletion(-)
>
>
>> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
>> index bc7c7d2..daf8bab 100644
>> --- a/drivers/net/phy/micrel.c
>> +++ b/drivers/net/phy/micrel.c
>> @@ -417,7 +417,26 @@ static int ksz8873mll_read_status(struct phy_device
>> *phydev)
>>
>>   static int ksz8873mll_config_aneg(struct phy_device *phydev)
>>   {
>> -       return 0;
>
>
>    Eh? The function returns *int* and you're removing the only *return*
> statement?

Oops, thanks for catching this. I'll address and respin.

>
>> +}
>
>
> WBR, Sergei
>
