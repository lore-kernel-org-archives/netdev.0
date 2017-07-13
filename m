From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v7 3/3] net/cxgb4: Use new PCI_DEV_FLAGS_NO_RELAXED_ORDERING
 flag
Date: Thu, 13 Jul 2017 11:17:28 -0700
Message-ID: <CAKgT0Uf8Tg6AFthXt-bJrdNHCqJ3MfzduR1yCMMsjLYoEFXb-w@mail.gmail.com>
References: <1499955692-26556-1-git-send-email-dingtianhong@huawei.com>
 <1499955692-26556-4-git-send-email-dingtianhong@huawei.com> <CAKgT0UcBFBk9T7g0Dh-rHY6Z+6-4=5jsUWHbLcSMc+ohdTz=CA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Casey Leedom <leedom@chelsio.com>, Ashok Raj <ashok.raj@intel.com>,
        Bjorn Helgaas <bhelgaas@google.com>,
        Bjorn Helgaas <helgaas@kernel.org>,
        Michael Werner <werner@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Asit K Mallick <asit.k.mallick@intel.com>,
        Patrick J Cramer <patrick.j.cramer@intel.com>,
        Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>,
        Bob Shaw <Bob.Shaw@amd.com>, h <l.stach@pengutronix.de>,
        Amir Ancel <amira@mellanox.com>,
        Gabriele Paoloni <gabriele.paoloni@huawei.com>,
        David Laight <David.Laight@aculab.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Robin Murphy <robin.murphy@arm.com>,
        David Miller <davem@davem
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAKgT0UcBFBk9T7g0Dh-rHY6Z+6-4=5jsUWHbLcSMc+ohdTz=CA@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 13, 2017 at 11:14 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Thu, Jul 13, 2017 at 7:21 AM, Ding Tianhong <dingtianhong@huawei.com> wrote:
>> From: Casey Leedom <leedom@chelsio.com>
>>
>> cxgb4 Ethernet driver now queries PCIe configuration space to determine
>> if it can send TLPs to it with the Relaxed Ordering Attribute set.
>>
>> Remove the enable_pcie_relaxed_ordering() to avoid enable PCIe Capability
>> Device Control[Relaxed Ordering Enable] at probe routine, to make sure
>> the driver will not send the Relaxed Ordering TLPs to the Root Complex which
>> could not deal the Relaxed Ordering TLPs.
>>
>> Signed-off-by: Casey Leedom <leedom@chelsio.com>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>
> Ding,
>
> You can probably just drop this patch. If I am understanding Casey
> correctly just the fact that the relaxed ordering enable bit is
> cleared in the configuration should be enough to do this for the
> device automatically.
>
> - Alex

Actually I take that back. I hadn't caught the most recent parts of
the thread. If this is good for Casey then this works for me.

- Alex
