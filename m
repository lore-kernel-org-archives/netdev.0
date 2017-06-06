From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ppp: mppe: Use vsnprintf extension %phN
Date: Tue, 06 Jun 2017 15:16:47 -0400 (EDT)
Message-ID: <20170606.151647.343740453758118261.davem@davemloft.net>
References: <80f51106926c82374f6555b54af71a674b8bf94e.1496665332.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, linux-ppp@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <80f51106926c82374f6555b54af71a674b8bf94e.1496665332.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon,  5 Jun 2017 05:22:50 -0700

> Using this extension reduces the object size.
> 
> $ size drivers/net/ppp/ppp_mppe.o*
>    text	   data	    bss	    dec	    hex	filename
>    5683	    216	      8	   5907	   1713	drivers/net/ppp/ppp_mppe.o.new
>    5808	    216	      8	   6032	   1790	drivers/net/ppp/ppp_mppe.o.old
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied to net-next, thanks Joe.
