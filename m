From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH 4/4] microblaze: Remove NO_IRQ from architecture
Date: Thu, 22 Dec 2011 09:06:34 +0100
Message-ID: <4EF2E50A.7040506@monstr.eu>
References: <1324477932-19262-1-git-send-email-monstr@monstr.eu> <1324477932-19262-2-git-send-email-monstr@monstr.eu> <1324477932-19262-3-git-send-email-monstr@monstr.eu> <1324477932-19262-4-git-send-email-monstr@monstr.eu> <4EF258FE.9030709@gmail.com>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Ryan Mallon <rmallon@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EF258FE.9030709@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ryan Mallon wrote:
> On 22/12/11 01:32, Michal Simek wrote:
> 
>> NO_IRQ shouldn't be used by any driver. All Microblaze
>> drivers are fixed that's why NO_IRQ can be removed.
> 
> 
> This only describes half of what the patch does. You should also state
> that arch/microblaze/pci/pci-common.c has references to NO_IRQ removed.
> Maybe it' worth splitting this patch in half so the final patch just
> does the removal of the NO_IRQ definition, but maybe that is overkill?

I have decided to remove NO_IRQ from arch/microblaze in one patch.
It is less painful because if there is any problem with PCI you can revert
just one patch instead of two.

Drivers out of arch/microblaze must be in separate patches.


> Other than that, for the whole series:
> 
> Reviewed-by: Ryan Mallon <rmallon@gmail.com>

Thanks,
Michal


-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
