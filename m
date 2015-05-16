From: "Suthikulpanit, Suravee" <Suravee.Suthikulpanit@amd.com>
Subject: Re: [V4 PATCH 3/6] pci: Generic function for setting up PCI device
 DMA coherency
Date: Sat, 16 May 2015 15:14:36 +0000
Message-ID: <D17CC88E.1AFDA%suravee.suthikulpanit@amd.com>
References: <CAErSpo7NkeXvtFH7jDNeYm6HTZO_G=r77EuJ8vOL4WUKSpQxAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>,
	"Catalin Marinas" <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	"Lendacky, Thomas" <Thomas.Lendacky@amd.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	"Arnd Bergmann" <arnd@arndb.de>, Mark Salter <msalter@redhat.com>,
	Hanjun Guo <hanjun.guo@linaro.org>,
	Al Stone <al.stone@linaro.org>,
	Grant Likely <grant.likely@linaro.org>,
	"Duran, Leo" <leo.duran@amd.com>,
	linux-arm <linux-arm-kernel@lists.infradead.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linaro-acpi@lists.linaro.org" <linaro-acpi@lists.linaro.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
	Rob Herring <robh+dt@kernel.org>,
	Murali Karicheri
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAErSpo7NkeXvtFH7jDNeYm6HTZO_G=r77EuJ8vOL4WUKSpQxAQ@mail.gmail.com>
Content-Language: en-US
Content-ID: <A54407A3CA8E064EA1BE257A105403DE@amd.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Bjorn,

On 5/16/15, 07:41, "Bjorn Helgaas" <bhelgaas@google.com> wrote:

>On Fri, May 15, 2015 at 4:23 PM, Suravee Suthikulpanit
><Suravee.Suthikulpanit@amd.com> wrote:
>> This patch refactors of_pci_dma_configure() into a more generic
>> pci_dma_configure(), which can be reused by non-OF code.
>> Then, it adds support for setting up PCI device DMA coherency from
>> ACPI _CCA object that should normally be specified in the DSDT node
>> of its PCI host bridge..
>
>From the changelog, it sounds like you might be able to split this
>into two patches:
>
>1) Refactor of_pci_dma_configure(), with no functional change
>2) Add support for using _CCA
>
>If that's possible, please do so to make this easier to review.
>
>Bjorn

Yes, I can separate the patch out. This would mainly affect ACPI+PCI
support for ARM64 (which is in progress).

Thanks,

Surafvee
