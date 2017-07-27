From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v7 2/3] PCI: Enable PCIe Relaxed Ordering if supported
Date: Thu, 27 Jul 2017 10:49:25 -0700
Message-ID: <CAKgT0UcqdRCwDDxD=22Q_jLuqz8KVHwH1-V45Aq-1WzQw=agcA@mail.gmail.com>
References: <1499955692-26556-1-git-send-email-dingtianhong@huawei.com>
 <1499955692-26556-3-git-send-email-dingtianhong@huawei.com>
 <e496ff1d-b836-ebef-fdf7-76273aaaaef6@codeaurora.org> <0260e398-bd8e-6615-6d5c-1f7c07b6fc09@huawei.com>
 <67be791f-e0cf-8284-9229-17174dc741ef@codeaurora.org> <5f9b8bfb-41a8-a17c-6fea-581aec1d5573@huawei.com>
 <20170724090516.2e0f0d2a@w520.home> <MWHPR12MB1600065968964410EDFBDA3BC8B90@MWHPR12MB1600.namprd12.prod.outlook.com>
 <75213fca-4522-2297-3cb8-338e643d3552@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Casey Leedom <leedom@chelsio.com>,
        Alex Williamson <alex.williamson@redhat.com>,
        Sinan Kaya <okaya@codeaurora.org>,
        "ashok.raj@intel.com" <ashok.raj@intel.com>,
        "bhelgaas@google.com" <bhelgaas@google.com>,
        "helgaas@kernel.org" <helgaas@kernel.org>,
        Michael Werner <werner@chelsio.com>,
        Ganesh GR <ganeshgr@chelsio.com>,
        "asit.k.mallick@intel.com" <asit.k.mallick@intel.com>,
        "patrick.j.cramer@intel.com" <patrick.j.cramer@intel.com>,
        "Suravee.Suthikulpanit@amd.com" <Suravee.Suthikulpanit@amd.com>,
        "Bob.Shaw@amd.com" <Bob.Shaw@amd.com>,
        "l.stach@pengutronix.de" <l.stach@pengutronix.de>,
        "amira@mellanox.com" <amira@mellanox.com>,
        "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
        "David.Laight@aculab.com" <David.Laight@aculab.com>,
        "jeffrey.t.kirsher@int
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <75213fca-4522-2297-3cb8-338e643d3552@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 26, 2017 at 6:08 PM, Ding Tianhong <dingtianhong@huawei.com> wrote:
>
>
> On 2017/7/27 2:26, Casey Leedom wrote:
>>   By the way Ding, two issues:
>>
>>  1. Did we ever get any acknowledgement from either Intel or AMD
>>     on this patch?  I know that we can't ensure that, but it sure would
>>     be nice since the PCI Quirks that we're putting in affect their
>>     products.
>>
>
> Still no Intel and AMD guys has ack this, this is what I am worried about, should I
> ping some man again ?
>
> Thanks
> Ding


I probably wouldn't worry about it too much. If anything all this
patch is doing is disabling relaxed ordering on the platforms we know
have issues based on what Casey originally had. If nothing else we can
follow up once the patches are in the kernel and if somebody has an
issue then.

You can include my acked-by, but it is mostly related to how this
interacts with NICs, and not so much about the PCI chipsets
themselves.

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
