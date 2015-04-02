From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [rhashtable] [ INFO: suspicious RCU usage. ]
Date: Thu, 2 Apr 2015 08:33:56 +0100
Message-ID: <20150402073356.GC19425@casper.infradead.org>
References: <20150402005211.GC12979@wfg-t540p.sh.intel.com>
 <20150402035810.GA5408@gondor.apana.org.au>
 <20150402041135.GA22514@wfg-t540p.sh.intel.com>
 <20150402042950.GA5643@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fengguang Wu <fengguang.wu@intel.com>, LKP <lkp@01.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150402042950.GA5643@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/02/15 at 12:29pm, Herbert Xu wrote:
> On Thu, Apr 02, 2015 at 12:11:35PM +0800, Fengguang Wu wrote:
> > 
> > Yes it is contained in next-20150401 which is bad:
> > 
> > # extra tests on tree/branch next/master
> > git bisect  bad e954104e2b634b42811dad8d502cbf240f206df2  # 21:22      0-     60  Add linux-next specific files for 20150401
> > 
> > The dmesg there is
> > 
> > [    1.149409] test_firmware: interface ready
> > [    1.150293] Running resizable hashtable tests...
> > [    1.151209]   Adding 2048 keys
> > [    1.152069] ------------[ cut here ]------------
> > [    1.152978] WARNING: CPU: 0 PID: 1 at lib/rhashtable.c:409 rhashtable_insert_rehash+0x9d/0x1d0()
> 
> I see.  This is actually a completely different problem.
> 
> ---8<---
> test_rhashtable: Remove bogus max_size setting
> 
> Now that resizing is completely automatic, we need to remove
> the max_size setting or the test will fail.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Thomas Graf <tgraf@suug.ch>

Had the same fix queued up in an upcoming series ;-)
