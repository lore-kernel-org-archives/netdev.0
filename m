From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [V4 PATCH 2/6] arm64 : Introduce support for ACPI _CCA object
Date: Sat, 16 May 2015 13:48:07 +0200
Message-ID: <1431776887.2341.17.camel@x220>
References: <1431724994-21601-1-git-send-email-Suravee.Suthikulpanit@amd.com>
	 <1431724994-21601-3-git-send-email-Suravee.Suthikulpanit@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: rjw@rjwysocki.net, lenb@kernel.org, catalin.marinas@arm.com,
	will.deacon@arm.com, bhelgaas@google.com, thomas.lendacky@amd.com,
	herbert@gondor.apana.org.au, davem@davemloft.net, arnd@arndb.de,
	msalter@redhat.com, hanjun.guo@linaro.org, al.stone@linaro.org,
	grant.likely@linaro.org, leo.duran@amd.com,
	linux-arm-kernel@lists.infradead.org, linux-acpi@vger.kernel.org,
	linux-kernel@vger.kernel.org, linaro-acpi@lists.linaro.org,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1431724994-21601-3-git-send-email-Suravee.Suthikulpanit@amd.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just a nit regarding the commit explanation.

On Fri, 2015-05-15 at 16:23 -0500, Suravee Suthikulpanit wrote:
> From http://www.uefi.org/sites/default/files/resources/ACPI_6.0.pdf,
> section 6.2.17 _CCA states that ARM platforms require ACPI _CCA
> object to be specified for DMA-cabpable devices. This patch introduces
> ACPI_MUST_HAVE_CCA in arm64 Kconfig to specify such requirement.

s/ACPI_MUST_HAVE_CCA/ACPI_CCA_REQUIRED/.

Ie, update the commit explanation to match the change introduced in V2.

> In case _CCA is missing, arm64 would assign dummy_dma_ops
> to disable DMA capability of the device.

Thanks,


Paul Bolle

