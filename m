From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] staging: irda: force to be a kernel module
Date: Tue, 29 Aug 2017 09:35:07 -0700 (PDT)
Message-ID: <20170829.093507.2166038228205751885.davem@davemloft.net>
References: <20170829070929.GA15824@kroah.com>
 <20170829091417.GA9481@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org, samuel@sortiz.org,
 linux-kernel@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170829091417.GA9481@kroah.com>
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

From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 29 Aug 2017 11:14:17 +0200

> Now that the IRDA networking code has moved into drivers/staging/, the
> link order is changed for when it is initialized if built into the
> system.  This can cause a crash when initializing as the netfilter core
> hasn't been initialized yet.
> 
> So force the IRDA code to be built as a module, preventing the crash.
> 
> Reported-by: kernel test robot <fengguang.wu@intel.com>
> Signed-off-by: Greg Kroah-Hartman gregkh@linuxfoundation.org

I don't think this is reasonable.

IRDA being built in was broken by moving it to staging, so it's a
regression and we should find a way to fix it.

It's one thing if IRDA on it's own has deteriorated and broken in some
ways over time due to lack of maintainence, it's another to knowingly
do something to it that causes a regression which is what happened
here.

Thanks.
