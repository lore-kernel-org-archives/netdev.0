From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch linux-2.6.13-rc2-gitXX 1/1] zatm: mailbox converted to
 pci_alloc_consistent()
Date: Wed, 20 Jul 2005 12:02:19 -0700 (PDT)
Message-ID: <20050720.120219.75429205.davem@davemloft.net>
References: <200507192044.j6JKirFb027183@ginger.cmf.nrl.navy.mil>
	<20050719223134.GA24535@electric-eye.fr.zoreil.com>
	<20050719223655.GA27724@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: romieu@fr.zoreil.com
In-Reply-To: <20050719223655.GA27724@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 20 Jul 2005 00:36:55 +0200

> mailbox converted to pci_alloc_consistent()
> 
> - request_region() is not needed: zatm_init_one() issues
>   pci_request_regions();
> - the warning related to kfree(zatm_dev->mbx_start) disappears;
> 
> Compiled with i386 and sparc64 as target.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

This looks great, applied.
