From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net/irda: bfin_sir: remove duplicate defines
Date: Thu, 21 Jan 2016 10:45:55 -0800 (PST)
Message-ID: <20160121.104555.194909626689511824.davem@davemloft.net>
References: <1453353151-4622-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org, realmz6-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1453353151-4622-1-git-send-email-sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 21 Jan 2016 10:42:31 +0530

> The defconfig build of blackfin is failing with the error:
> 
> arch/blackfin/include/asm/bfin_serial.h:269:0: warning: "port_membase" redefined
> drivers/net/irda/bfin_sir.h:85:0: note: this is the location of the previous definition
> arch/blackfin/include/asm/bfin_serial.h:382:0: warning: "get_lsr_cache" redefined
> drivers/net/irda/bfin_sir.h:86:0: note: this is the location of the previous definition
> arch/blackfin/include/asm/bfin_serial.h:383:0: warning: "put_lsr_cache" redefined
> drivers/net/irda/bfin_sir.h:87:0: note: this is the location of the previous definition
> 
> port_membase, get_lsr_cache, put_lsr_cache are already defined in the
> architecture files, no need to define them again in the driver.
> 
> Signed-off-by: Sudip Mukherjee <sudip-ofJRbWXBVFamYgehrs7/Lw@public.gmane.org>

Applied, thank you.
