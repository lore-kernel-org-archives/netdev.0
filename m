From: Suravee Suthikulanit <suravee.suthikulpanit@amd.com>
Subject: Re: [V2 PATCH 2/5] arm64 : Introduce support for ACPI _CCA object
Date: Wed, 6 May 2015 09:34:25 -0500
Message-ID: <554A2671.8020804@amd.com>
References: <1430838729-21572-1-git-send-email-Suravee.Suthikulpanit@amd.com>
 <1430838729-21572-3-git-send-email-Suravee.Suthikulpanit@amd.com>
 <5549E834.1040305@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "al.stone@linaro.org" <al.stone@linaro.org>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"linaro-acpi@lists.linaro.org" <linaro-acpi@lists.linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	"leo.duran@amd.com" <leo.duran@amd.com>,
	"hanjun.guo@linaro.org" <hanjun.guo@linaro.org>,
	"msalter@redhat.com" <msalter@redhat.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>
To: Robin Murphy <robin.murphy@arm.com>,
	"rjw@rjwysocki.net" <rjw@rjwysocki.net>,
	"lenb@kernel.org" <lenb@kernel.org>,
	Catalin Marinas <Catalin.Marinas@arm.com>,
	Will Deacon <Will.Deacon@arm.com>,
	"thomas.lendacky@amd.com" <thomas.lendacky@amd.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <5549E834.1040305@arm.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/6/2015 5:08 AM, Robin Murphy wrote:
> [...]
>> +static void __dummy_sync_single_for_cpu(struct device *dev,
>> +                    dma_addr_t dev_addr, size_t size,
>> +                    enum dma_data_direction dir)
>> +{
>> +}
>> +
>> +static void __dummy_sync_single_for_device(struct device *dev,
>> +                       dma_addr_t dev_addr, size_t size,
>> +                       enum dma_data_direction dir)
>> +{
>> +}
>
> Minor point, but I don't see the need to have multiple dummy functions
> with identical signatures - just have a generic dummy_sync_single and
> assign it to both ops.
>
>> +static void __dummy_sync_sg_for_cpu(struct device *dev,
>> +                    struct scatterlist *sgl, int nelems,
>> +                    enum dma_data_direction dir)
>> +{
>> +}
>> +
>> +static void __dummy_sync_sg_for_device(struct device *dev,
>> +                       struct scatterlist *sgl, int nelems,
>> +                       enum dma_data_direction dir)
>> +{
>> +}
>
> Ditto here with dummy_sync_sg.

Hi Robin,

Good point. I'll take care of that in V3.

>
> I wonder if there's any argument for putting the dummy DMA ops somewhere
> common, like drivers/base/dma-mapping.c?
>
> Robin.

Hm.. If this approach will be adopted by other architectures, then it 
would make sense. Currently, this is only used by arm64. So, I think it 
is okay to leave this here for now.

Thanks,
Suravee

