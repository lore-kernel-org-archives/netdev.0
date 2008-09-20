From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] convert sbmac tx to spin_lock_irqsave to prevent early
	IRQ enable
Date: Sat, 20 Sep 2008 22:18:39 +0200
Message-ID: <20080920201839.GA27700@linux-mips.org>
References: <6781da3918e3c34d23e5f7e9cf777ab463a17d5e.1221613284.git.weiwei.wang@windriver.com> <20080917114051.GA30734@shell.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Weiwei Wang <weiwei.wang@windriver.com>, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@redhat.com>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <20080917114051.GA30734@shell.devel.redhat.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 17, 2008 at 07:40:51AM -0400, Jeff Garzik wrote:

> On Wed, Sep 17, 2008 at 10:25:37AM +0800, Weiwei Wang wrote:
> > Netpoll will call the interrupt handler with interrupts
> > disabled when using kgdboe, so spin_lock_irqsave() should
> > be used instead of spin_lock_irq() to prevent interrupts
> > from being incorrectly enabled.
> > 
> > Signed-off-by: Weiwei Wang <weiwei.wang@windriver.com>
> > ---
> >  drivers/net/sb1250-mac.c |   12 +++++++-----
> >  1 files changed, 7 insertions(+), 5 deletions(-)
> 
> Please send to jeff@garzik.org or jgarzik@pobox.com.

Jeff - I haven't looked at kgdboe but if he's right half of drivers/net
will need to be fixed ...

  Ralf
