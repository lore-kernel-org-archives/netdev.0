From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: In tree firmware not kept up to date
Date: Tue, 17 Apr 2012 17:01:17 +0000
Message-ID: <1334682077.6288.212.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1334675504.23948.99.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"Ian Jackson" <Ian.Jackson@eu.citrix.com>,
	"David Miller" <davem@davemloft.net>,
	"Ben Hutchings" <bhutchings@solarflare.com>
To: "Ian Campbell" <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334675504.23948.99.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-04-17 at 16:11 +0100, Ian Campbell wrote: 
> Hello,
> 
> What is the current policy wrt keeping the in-tree firmware updated
> alongside the drivers?
> 
> I use CONFIG_FIRMWARE_IN_KERNEL but a couple of times[0] recently this
> has failed me because the in-tree bnx2 driver requires
> bnx2/bnx2-mips-09-6.2.1b.fw but the tree contains
> firmware/bnx2/bnx2-mips-09-6.2.1a.fw.ihex and not 6.2.1b.
> 
> Is it a bug that bnx2 was updated without adding the new firmware or is
> a bug that the obsolete firmware is still sitting in the tree?

We probably should remove the obsolete firmware in the kernel tree.  All
the firmware files to support old and new kernels are here:

git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
