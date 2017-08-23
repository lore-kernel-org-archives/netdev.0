From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: Re: [PATCH V8 net-next 00/22] Huawei HiNIC Ethernet Driver
Date: Wed, 23 Aug 2017 13:46:24 +0300
Message-ID: <f0b00e85-3cc0-1b80-94d4-41c7ab58dc15@huawei.com>
References: <cover.1503330613.git.aviad.krawczyk@huawei.com>
 <CAK8P3a3sWBZKZTz8YM2DfNwsLSWZpaS_e-Uh1VVKuCL6q+si3g@mail.gmail.com>
 <e8db1165-06da-324a-37e5-13d670fb0499@huawei.com>
 <CAK8P3a0St2mZ7q33zccHZ1uPyv0FKf2A+q+cMk+LN_L_qjxfkg@mail.gmail.com>
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
In-Reply-To: <CAK8P3a0St2mZ7q33zccHZ1uPyv0FKf2A+q+cMk+LN_L_qjxfkg@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> It's clear that ...

Sorry, but there are wrong assumptions here.

Thanks,
Aviad

On 8/23/2017 1:37 PM, Arnd Bergmann wrote:
> On Wed, Aug 23, 2017 at 11:31 AM, Aviad Krawczyk
> <aviad.krawczyk@huawei.com> wrote:
>> Hi Arnd,
>>
>> This is Huawei's PCIE HiNIC card.
>>
>> I am not familiar with the HiSilicon product and I don't see how
>> Huawei's PCIE HiNIC card is connected to the HiSilicon drivers on Linux Tree.
>>
>> I don't see how it can be shared: different product and different code.
> 
> Sharing code was just a wild thought of mine, as I said I had not looked at
> whether there is anything that can be shared.
> 
> However, simply moving drivers/net/ethernet/huawei/hinic to
> drivers/net/ethernet/hisilicon/hinic/ still seems to be the right thing and
> is a trivial patch.
> 
> It's clear that hinic is made by HiSilicon and that hns/hns3 are used
> exclusively in Huawei, and maintained by Huawei developers, so it's
> probably just a matter of time before the IP block from the SoC makes
> it into a future PCI device or vice versa. Merging the two directories
> now makes this easier to handle in the future and (slightly) reduces
> the clutter in the top-level drivers/net/ethernet/Kconfig file.
> 
>      Arnd
> 
> .
> 
