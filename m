From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: WARNING: drivers/net/ethernet/broadcom/tg3.o(.text+0x16006):
 Section mismatch in reference from the function tg3_get_invariants() to the
 variable .devinit.rodata:tg3_write_reorder_chipsets
Date: Tue, 4 Dec 2012 12:30:25 -0800
Message-ID: <20121204203025.GA32674@kroah.com>
References: <50be5bf5./vbd9l3rQvm4EYDg%fengguang.wu@intel.com>
 <20121204.152825.1014358628158241121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fengguang.wu@intel.com, wfp5p@virginia.edu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:58272 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169Ab2LDUaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 15:30:30 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so1949181dak.19
        for <netdev@vger.kernel.org>; Tue, 04 Dec 2012 12:30:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121204.152825.1014358628158241121.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 04, 2012 at 03:28:25PM -0500, David Miller wrote:
> From: kbuild test robot <fengguang.wu@intel.com>
> Date: Wed, 05 Dec 2012 04:24:21 +0800
> 
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> > head:   193c1e478cc496844fcbef402a10976c95a634ff
> > commit: 229b1ad1cb1a7159658f466c736bc3898dabb876 tg3: remove __dev* attributes
> > date:   25 hours ago
> > config: make ARCH=x86_64 allmodconfig
> > 
> > All warnings:
> 
> This is a result of the __dev* macro removal from the networking
> drivers.  I think it will be resolved when Greg KH's tree gets merged.
> 
> The issue is that the PCI device ID macros in linux/pci.h still
> use the __dev* tags.
> 
> Greg, please confirm.

Yes, that is correct.  Fengguang, you can stop reporting these kinds of
warnings, you are going to get a bunch of them from now until 3.8-rc1 is
out.

thanks,

greg k-h
