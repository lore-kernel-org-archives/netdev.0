From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [V4 PATCH 3/6] pci: Generic function for setting up PCI device
 DMA coherency
Date: Sat, 16 May 2015 07:41:14 -0500
Message-ID: <CAErSpo7NkeXvtFH7jDNeYm6HTZO_G=r77EuJ8vOL4WUKSpQxAQ@mail.gmail.com>
References: <1431724994-21601-1-git-send-email-Suravee.Suthikulpanit@amd.com> <1431724994-21601-4-git-send-email-Suravee.Suthikulpanit@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>, thomas.lendacky@amd.com,
	herbert@gondor.apana.org.au, David Miller <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>,
	Mark Salter <msalter@redhat.com>,
	Hanjun Guo <hanjun.guo@linaro.org>,
	Al Stone <al.stone@linaro.org>,
	Grant Likely <grant.likely@linaro.org>, leo.duran@amd.com,
	linux-arm <linux-arm-kernel@lists.infradead.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linaro-acpi@lists.linaro.org, netdev <netdev@vger.kernel.org>,
	linux-crypto@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
	Murali Karicheri <m-karicheri2@ti.com>
To: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1431724994-21601-4-git-send-email-Suravee.Suthikulpanit@amd.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 15, 2015 at 4:23 PM, Suravee Suthikulpanit
<Suravee.Suthikulpanit@amd.com> wrote:
> This patch refactors of_pci_dma_configure() into a more generic
> pci_dma_configure(), which can be reused by non-OF code.
> Then, it adds support for setting up PCI device DMA coherency from
> ACPI _CCA object that should normally be specified in the DSDT node
> of its PCI host bridge..

>From the changelog, it sounds like you might be able to split this
into two patches:

1) Refactor of_pci_dma_configure(), with no functional change
2) Add support for using _CCA

If that's possible, please do so to make this easier to review.

Bjorn
