From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH V8 net-next 00/22] Huawei HiNIC Ethernet Driver
Date: Wed, 23 Aug 2017 09:37:15 +0200
Message-ID: <CAK8P3a3sWBZKZTz8YM2DfNwsLSWZpaS_e-Uh1VVKuCL6q+si3g@mail.gmail.com>
References: <cover.1503330613.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>, bc.y@huawei.com,
        victor.gissin@huawei.com, zhaochen6@huawei.com, tony.qu@huawei.com
To: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1503330613.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2017 at 5:55 PM, Aviad Krawczyk
<aviad.krawczyk@huawei.com> wrote:
> The patch-set contains the support of the HiNIC Ethernet driver for
> hinic family of PCIE Network Interface Cards.
>
> The Huawei's PCIE HiNIC card is a new Ethernet card and hence there was
> a need of a new driver.
>
> The current driver is meant to be used for the Physical Function and there
> would soon be a support for Virtual Function and more features once the
> basic PF driver has been accepted.

Sorry I didn't comment before it got merged, but once it appeared in
linux-next I saw it and wondered why this is grouped under huawei
unlike the network drivers for the parts integrated into the hip0x
SoCs from hisilicon. Both appear to be made by Huawei's HiSilicon
subsidiary.

I did not check whether the two devices are related at all or could
share some of the source code as well, but it might be good to
move this one into the existing directory to spare confusion later.

         Arnd
