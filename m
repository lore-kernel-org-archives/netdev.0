From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH][2.6] de4x5 cleanup
Date: Sat, 30 Aug 2003 13:50:53 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3F50E3FD.1000703@pobox.com>
References: <wrpad9r79g6.fsf@hina.wild-wind.fr.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-net@vger.kernel.org,
	Maillist netdev <netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: mzyngier@freesurf.fr
In-Reply-To: <wrpad9r79g6.fsf@hina.wild-wind.fr.eu.org>
List-Id: netdev.vger.kernel.org

Marc Zyngier wrote:
> Jeff, Andrew,
> 
> The enclosed patch tries to clean the tulip de4x5 driver, and update
> it to some of the 2.6 APIs :
> 
> - Use PCI and EISA probing APIs
> - Use generic DMA API
> - Fix DE425 init on the Jensen
> - Remove de4x5 from Space.c
> 
> It's been tested on x86 and Alpha, with a DE425 (21040, EISA), a DE435
> (21040, PCI) and a quad DLink (4*21143, PCI).
> 
> The major problem with this patch is that, because of the Space.c
> removal, interfaces get potentially renumbered. This has been
> discussed to death on lkml, without any obvious solution. IMHO, we'd
> better remove as many drivers as we can from Space.c before
> 2.6.0-final ships...


It looks pretty good.  My big objection isn't the Space.c stuff but 
de4x5 itself.  I had hoped it would be gone by now :)  Oh well, not your 
fault.

A quick review of the patch looks good, and this is work that has long 
wanted doing (if de4x5 wasn't simply erased).  I'll apply after a more 
thorough review.

	Jeff



