From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Subject: Re: linux-next: Tree for March 29
Date: Sat, 29 Mar 2008 19:12:55 +0100
Message-ID: <20080329191255.7312e036@hskinnemo-gx620.norway.atmel.com>
References: <20080329223354.304e2722.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-ide@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754932AbYC2SNT@vger.kernel.org>
In-Reply-To: <20080329223354.304e2722.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> Status of my local build tests is at
> http://kisskb.ellerman.id.au/linux-next.  If maintainers want to give
> advice about cross compilers/configs that work, we are always open to add
> more builds.

I see both avr32 builds currently fail, but for different
reasons...none of which is avr32-specific as far as I can tell.

defconfig fails with

drivers/ata/libata-core.c:127: error: 'ata_pci_default_filter' undeclared here (not in a function)

which seems to be due to CONFIG_ATA && !CONFIG_PCI

allnoconfig fails with

include/linux/netdevice.h:843: error: implicit declaration of function 'dev_net'

which seems to be because the definition of dev_net is inside #ifdef
CONFIG_NET, while next_net_device, which calls it, is not.

Haavard
