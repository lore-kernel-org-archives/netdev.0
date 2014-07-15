From: Sitsofe Wheeler <sitsofe@gmail.com>
Subject: Re: [BISECTED][REGRESSION] Loading Hyper-V network drivers is racy
 in 3.14+ on Hyper-V 2012 R2
Date: Tue, 15 Jul 2014 06:08:32 +0100
Message-ID: <20140715050832.GA28549@sucs.org>
References: <20140706201800.GA10587@sucs.org>
 <941b0055b1a94c66b3a608ae67764d11@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140707181341.GA2646@sucs.org> <20140711055259.GA10317@sucs.org>
 <52afbe119b1a481aa1c80f909c3a2432@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140714213032.GA23639@sucs.org>
 <8b68f48141a045f784c10f9c081cd51f@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "David S. Miller" <davem@davemloft.net>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <8b68f48141a045f784c10f9c081cd51f@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 14, 2014 at 10:39:48PM +0000, Haiyang Zhang wrote:
> > -----Original Message-----
> > From: Sitsofe Wheeler [mailto:sitsofe@gmail.com]
> > Sent: Monday, July 14, 2014 5:31 PM
> > To: Haiyang Zhang
> > Cc: KY Srinivasan; David S. Miller; devel@linuxdriverproject.org; linux-
> > kernel@vger.kernel.org; netdev@vger.kernel.org
> > Subject: Re: [BISECTED][REGRESSION] Loading Hyper-V network drivers is
> > racy in 3.14+ on Hyper-V 2012 R2
> 
> Thanks for the tests! I will make a patch that can automatically retry
> smaller memory allocs when memory is insufficient.

This concerns me a bit - why would there be insufficient memory on a 64
bit VM with 4 GBytes of RAM just after startup (presumably the host's
memory isn't the issue)? Additionally, while things might fail just when
things are starting up, doing ifup eth0 at some point later succeeds so
whatever issue it had seems temporary.

Perhaps it would be wise to adding some debugging output to see if the
allocation really failed and why...

-- 
Sitsofe | http://sucs.org/~sits/
