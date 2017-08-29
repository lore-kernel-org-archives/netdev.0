From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 net-next] irda: fix link order if IRDA is built into
 the kernel
Date: Tue, 29 Aug 2017 21:05:03 +0200
Message-ID: <20170829190503.GA31452@kroah.com>
References: <20170829172608.GA4700@kroah.com>
 <20170829173129.GA11029@kroah.com>
 <20170829174622.GA25926@kroah.com>
 <20170829.104945.1786969849973428586.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, samuel@sortiz.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, geert@linux-m68k.org, fengguang.wu@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20170829.104945.1786969849973428586.davem@davemloft.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Tue, Aug 29, 2017 at 10:49:45AM -0700, David Miller wrote:
> From: Greg KH <gregkh@linuxfoundation.org>
> Date: Tue, 29 Aug 2017 19:46:22 +0200
> 
> > When moving the IRDA code out of net/ into drivers/staging/irda/net, the
> > link order changes when IRDA is built into the kernel.  That causes a
> > kernel crash at boot time as netfilter isn't initialized yet.
> > 
> > To fix this, build and link the irda networking code in the same exact
> > order that it was previously before the move.
> > 
> > Reported-by: kernel test robot <fengguang.wu@intel.com>
> > Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> > Signed-off-by: Greg Kroah-Hartman gregkh@linuxfoundation.org
> 
> Greg, just change the initializer in IRDA so that it will run
> after subsys_init() when built statically.
> 
> IRDA is definitely not the first pontentially statically built
> thing that needs netlink up and available.

Ok, will do that tomorrow and test it and send you the patch.

thanks,

greg k-h
