From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: modpost warning question
Date: Wed, 25 Jul 2007 09:52:05 +0200
Message-ID: <20070725075205.GC24093@uranus.ravnborg.org>
References: <Pine.LNX.4.64.0707250210520.14366@blarg.am.freescale.net>
	<20070725072712.GB24093@uranus.ravnborg.org>
	<1409C32B-61A8-49D1-BF64-1CFAA5F8B93B@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <1409C32B-61A8-49D1-BF64-1CFAA5F8B93B@kernel.crashing.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

> >
> >For the popular architectures (i386,x86_64) we discard .exit.text at
> >runtime so here we do not see the error from ld (sadly).
> 
> Fair point, wondering what we do with .exit on PPC, another thing for  
> the list :)

from:
arch/ppc/kernel/vmlinux.lds.S:
  /* .exit.text is discarded at runtime, not link time,
     to deal with references from __bug_table */
  .exit.text : { *(.exit.text) }

	Sam
