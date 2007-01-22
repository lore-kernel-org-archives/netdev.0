From: Luca Tettamanti <kronos.it@gmail.com>
Subject: Re: [PATCH 4/4] atl1: Ancillary C files for Attansic L1 driver
Date: Mon, 22 Jan 2007 21:00:04 +0100
Message-ID: <20070122200004.GA12553@dreamland.darkstar.lan>
References: <20070121210737.GE2702@osprey.hogchain.net> <20070121183151.4be61ebf.randy.dunlap@oracle.com> <45B43093.6060500@bellsouth.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Randy Dunlap <randy.dunlap@oracle.com>, jeff@garzik.org,
	shemminger@osdl.org, csnook@redhat.com, hch@infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	atl1-devel@lists.sourceforge.net, kronos.it@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:47825 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932433AbXAVUAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 15:00:10 -0500
Received: by nf-out-0910.google.com with SMTP id o25so6738nfa
        for <netdev@vger.kernel.org>; Mon, 22 Jan 2007 12:00:09 -0800 (PST)
To: Jay Cliburn <jacliburn@bellsouth.net>
Content-Disposition: inline
In-Reply-To: <45B43093.6060500@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Il Sun, Jan 21, 2007 at 09:33:39PM -0600, Jay Cliburn ha scritto: 
> Randy Dunlap wrote:
> >On Sun, 21 Jan 2007 15:07:37 -0600 Jay Cliburn wrote:
> [snip]
> 
> >>+	value = ioread16(hw->hw_addr + REG_PCIE_CAP_LIST);
> >>+	return ((value & 0xFF00) == 0x6C00) ? 0 : 1;
> >
> >Are there defines or enums for these?
> >Fewer magic numbers would be nice/helpful/readable.
> [snip]
> >>+	s32 ret;
> >>+	ret = atl1_write_phy_reg(hw, 29, 0x0029);
> >
> >Fewer magic numbers?
> 
> Unfortunately, we don't have a spec.  This is how the vendor coded it.
> 
> [snip]
> >>+
> >>+int enable_msi;
> >>+module_param(enable_msi, int, 0444);
> >>+MODULE_PARM_DESC(enable_msi, "Enable PCI MSI");
> >
> >Hm, I thought that we didn't want individual drivers having MSI config
> >options...
> 
> Luca?  This one was yours IIRC.  Care to chime in?

I remember that discussion, but since there's no sistem-wide MSI
blacklist (or whitelist) I don't think it's safe to enable it
unconditionally. Judging from bug reports on lkml it's not safe to
assume that MSI support is sane on non-Intel chipsets.

Luca
-- 
Il coraggio non mi manca.
E` la paura che mi frega...
