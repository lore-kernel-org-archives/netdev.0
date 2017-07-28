From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v7 2/3] PCI: Enable PCIe Relaxed Ordering if supported
Date: Fri, 28 Jul 2017 11:00:49 +0800
Message-ID: <14218972-553d-eb60-0207-460ac7f4b064@huawei.com>
References: <1499955692-26556-1-git-send-email-dingtianhong@huawei.com>
 <1499955692-26556-3-git-send-email-dingtianhong@huawei.com>
 <e496ff1d-b836-ebef-fdf7-76273aaaaef6@codeaurora.org>
 <0260e398-bd8e-6615-6d5c-1f7c07b6fc09@huawei.com>
 <67be791f-e0cf-8284-9229-17174dc741ef@codeaurora.org>
 <5f9b8bfb-41a8-a17c-6fea-581aec1d5573@huawei.com>
 <20170724090516.2e0f0d2a@w520.home>
 <MWHPR12MB1600065968964410EDFBDA3BC8B90@MWHPR12MB1600.namprd12.prod.outlook.com>
 <75213fca-4522-2297-3cb8-338e643d3552@huawei.com>
 <CAKgT0UcqdRCwDDxD=22Q_jLuqz8KVHwH1-V45Aq-1WzQw=agcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "mark.rutland@arm.com" <mark.rutland@arm.com>,
 "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
 "asit.k.mallick@intel.com" <asit.k.mallick@intel.com>,
 "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
 "will.deacon@arm.com" <will.deacon@arm.com>,
 "linuxarm@huawei.com" <linuxarm@huawei.com>, Sinan Kaya <okaya@codeaurora.org>,
 "ashok.raj@intel.com" <ashok.raj@intel.com>,
 "helgaas@kernel.org" <helgaas@kernel.org>,
 "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
 "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
 Ganesh GR <ganeshgr@chelsio.com>, "Bob.Shaw@amd.com" <Bob.Shaw@amd.com>,
 Casey Leedom <leedom@chelsio.com>,
 "patrick.j.cramer@intel.com" <patrick.j.cramer@intel.com>,
 Alex Williamson <alex.williamson@redhat.com>,
 "bhelgaas@google.com" <bhelgaas@google.com>, Michael
 Werner <werner@chelsio.com>,
 "linux-arm-kernel@lists.infradead.org"
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAKgT0UcqdRCwDDxD=22Q_jLuqz8KVHwH1-V45Aq-1WzQw=agcA@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org



On 2017/7/28 1:49, Alexander Duyck wrote:
> On Wed, Jul 26, 2017 at 6:08 PM, Ding Tianhong <dingtianhong@huawei.com> wrote:
>>
>>
>> On 2017/7/27 2:26, Casey Leedom wrote:
>>>   By the way Ding, two issues:
>>>
>>>  1. Did we ever get any acknowledgement from either Intel or AMD
>>>     on this patch?  I know that we can't ensure that, but it sure would
>>>     be nice since the PCI Quirks that we're putting in affect their
>>>     products.
>>>
>>
>> Still no Intel and AMD guys has ack this, this is what I am worried about, should I
>> ping some man again ?
>>
>> Thanks
>> Ding
> 
> 
> I probably wouldn't worry about it too much. If anything all this
> patch is doing is disabling relaxed ordering on the platforms we know
> have issues based on what Casey originally had. If nothing else we can
> follow up once the patches are in the kernel and if somebody has an
> issue then.
> 
> You can include my acked-by, but it is mostly related to how this
> interacts with NICs, and not so much about the PCI chipsets
> themselves.
> 
> Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
> 

Thanks, Alex. :)

> .
> 
