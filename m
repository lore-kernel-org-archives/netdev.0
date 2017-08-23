From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: Re: [PATCH V8 net-next 00/22] Huawei HiNIC Ethernet Driver
Date: Wed, 23 Aug 2017 12:31:44 +0300
Message-ID: <e8db1165-06da-324a-37e5-13d670fb0499@huawei.com>
References: <cover.1503330613.git.aviad.krawczyk@huawei.com>
 <CAK8P3a3sWBZKZTz8YM2DfNwsLSWZpaS_e-Uh1VVKuCL6q+si3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>, <bc.y@huawei.com>,
        <victor.gissin@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a3sWBZKZTz8YM2DfNwsLSWZpaS_e-Uh1VVKuCL6q+si3g@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

This is Huawei's PCIE HiNIC card.

I am not familiar with the HiSilicon product and I don't see how
Huawei's PCIE HiNIC card is connected to the HiSilicon drivers on Linux Tree.

I don't see how it can be shared: different product and different code.

Thanks,
Aviad


On 8/23/2017 10:37 AM, Arnd Bergmann wrote:
> On Mon, Aug 21, 2017 at 5:55 PM, Aviad Krawczyk
> <aviad.krawczyk@huawei.com> wrote:
>> The patch-set contains the support of the HiNIC Ethernet driver for
>> hinic family of PCIE Network Interface Cards.
>>
>> The Huawei's PCIE HiNIC card is a new Ethernet card and hence there was
>> a need of a new driver.
>>
>> The current driver is meant to be used for the Physical Function and there
>> would soon be a support for Virtual Function and more features once the
>> basic PF driver has been accepted.
> 
> Sorry I didn't comment before it got merged, but once it appeared in
> linux-next I saw it and wondered why this is grouped under huawei
> unlike the network drivers for the parts integrated into the hip0x
> SoCs from hisilicon. Both appear to be made by Huawei's HiSilicon
> subsidiary.
> 
> I did not check whether the two devices are related at all or could
> share some of the source code as well, but it might be good to
> move this one into the existing directory to spare confusion later.
> 
>          Arnd
> 
> .
> 
