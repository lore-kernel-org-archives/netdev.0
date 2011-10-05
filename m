From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/1] bna: Multiple Definition and Interface Setup Fix
Date: Tue, 04 Oct 2011 23:27:13 -0400 (EDT)
Message-ID: <20111004.232713.1345786533613742751.davem@davemloft.net>
References: <1317781880-26515-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org,
	rdunlap@xenotime.net, sfr@canb.auug.org.au, huangj@brocade.com,
	adapter_linux_open_src_team@brocade.com
To: rmody@brocade.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317781880-26515-1-git-send-email-rmody@brocade.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rasesh Mody <rmody@brocade.com>
Date: Tue, 4 Oct 2011 19:31:20 -0700

> drivers/net/built-in.o: In function `bfa_ioc_ct2_poweron':
> (.text+0xcdc90): multiple definition of `bfa_ioc_ct2_poweron'
> drivers/scsi/built-in.o:(.text+0x17f9a0): first defined here
> 
> This patch renames bfa_ioc_ct2_poweron() to bfa_nw_ioc_ct2_poweron() to avoid
> multiple definition with Brocade scsi driver. It also modifies asic specific
> interface setup to allocate MSIX resources at power on in case of 1860 HW with
> no asic block and warns if the asic gen is neither BFI_ASIC_GEN_CT nor
> BFI_ASIC_GEN_CT2.
> 
> Reported-by: Randy Dunlap <rdunlap@xenotime.net>
> Signed-off-by: Rasesh Mody <rmody@brocade.com>

Applied, thanks.
