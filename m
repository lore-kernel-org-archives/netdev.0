From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH net-next v2 2/9] net: ethernet: Change Ethernet Makefile
 and Kconfig for Altera TSE driver
Date: Tue, 11 Mar 2014 10:46:19 -0500
Message-ID: <CAOwfj2O_vZ=2Dah5qycV2-tVm1hG6OxrcHZSzqhM8+tWFUBtMw@mail.gmail.com>
References: <1394493277-2105-1-git-send-email-vbridgers2013@gmail.com>
	<1394493277-2105-3-git-send-email-vbridgers2013@gmail.com>
	<531F1928.4080505@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Landley <rob@landley.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <531F1928.4080505@cogentembedded.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On Tue, Mar 11, 2014 at 9:09 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
>
> On 11-03-2014 3:14, Vince Bridgers wrote:
>
>> This patch changes the Ethernet Makefile and Kconfig files to add the
>> Altera
>> Ethernet driver component.
>
>
>> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
>> ---
>> V2: - No change to Kconfig and Makefile from initial RFC review
>
>
>    Unfortunately, the order of patches seems wrong. This patch should be
> among the last.
>
>
>> ---
>>   drivers/net/ethernet/Kconfig  |    1 +
>>   drivers/net/ethernet/Makefile |    1 +
>>   2 files changed, 2 insertions(+)
>
>
>> diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
>> index 506b024..39484b5 100644
>> --- a/drivers/net/ethernet/Kconfig
>> +++ b/drivers/net/ethernet/Kconfig
>> @@ -22,6 +22,7 @@ source "drivers/net/ethernet/adaptec/Kconfig"
>>   source "drivers/net/ethernet/aeroflex/Kconfig"
>>   source "drivers/net/ethernet/allwinner/Kconfig"
>>   source "drivers/net/ethernet/alteon/Kconfig"
>> +source "drivers/net/ethernet/altera/Kconfig"
>
>
>    This file doesn't exist yet.
>
>
>>   source "drivers/net/ethernet/amd/Kconfig"
>>   source "drivers/net/ethernet/apple/Kconfig"
>>   source "drivers/net/ethernet/arc/Kconfig"
>> diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
>> index c0b8789..adf61af 100644
>> --- a/drivers/net/ethernet/Makefile
>> +++ b/drivers/net/ethernet/Makefile
>> @@ -8,6 +8,7 @@ obj-$(CONFIG_NET_VENDOR_ADAPTEC) += adaptec/
>>   obj-$(CONFIG_GRETH) += aeroflex/
>>   obj-$(CONFIG_NET_VENDOR_ALLWINNER) += allwinner/
>>   obj-$(CONFIG_NET_VENDOR_ALTEON) += alteon/
>> +obj-$(CONFIG_ALTERA_TSE) += altera/
>
>
>    This directory doesn't exist yet.
>
> WBR, Sergei
>

Understood, this was an oversight on my part when I created the
patchset. I'll address and respin.

Thank you for taking the time to review and comment,

All the best,

Vince
