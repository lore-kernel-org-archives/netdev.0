From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net-next, v4] hyperv: Add support for virtual Receive Side
 Scaling (vRSS)
Date: Tue, 25 Mar 2014 20:49:55 -0700
Message-ID: <20140326034955.GA10875@kroah.com>
References: <1395434633-16771-1-git-send-email-haiyangz@microsoft.com>
 <216cd74854414cfc9b338cab41a3d1a0@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140325.204343.991901655152875043.davem@davemloft.net>
 <20140325.204728.2281772666453524010.davem@davemloft.net>
 <a8b374e420be42d883fb782c8f271659@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 David Miller <davem@davemloft.net>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <a8b374e420be42d883fb782c8f271659@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
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

On Wed, Mar 26, 2014 at 03:23:47AM +0000, Haiyang Zhang wrote:
> 
> 
> > -----Original Message-----
> > From: David Miller [mailto:davem@davemloft.net]
> > Sent: Tuesday, March 25, 2014 8:47 PM
> > To: Haiyang Zhang
> > Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> > jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
> > devel@linuxdriverproject.org
> > Subject: Re: [PATCH net-next,v4] hyperv: Add support for virtual Receive
> > Side Scaling (vRSS)
> > 
> > From: David Miller <davem@davemloft.net>
> > Date: Tue, 25 Mar 2014 20:43:43 -0400 (EDT)
> > 
> > > From: Haiyang Zhang <haiyangz@microsoft.com>
> > > Date: Tue, 25 Mar 2014 20:37:43 +0000
> > >
> > >> Do we know when the dependency (commit: 8a7206a89f) will be merged
> > >> into net-next tree?
> > >
> > > You're really not very patient, to say the least.
> > >
> > > It's done now and I'm working to integrate your patch.
> > >
> > > That patch has been in under review state in patchwork, which means
> > > that I will get to it at some point, so you don't need to worry about
> > > it any more than any other patch you might submit.
> > >
> > > The whole reason patchwork exists is so that people don't have to
> > > ask.
> > 
> > And actually, this dependency "8a7206a89f" commit doesn't exist
> > in the 'net' tree at all.  I just merged Linus's tree into 'net'
> > and it doesn't exist there either.
> > 
> > So this patch still doesn't compile.
> > 
> > I'm tossing it from patchwork until you sort this out.
> 
> Dave,
> 
> Thank you for the efforts.
> The commit is in the linux-next tree. You can see it from this link:
> http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=8a7206a89f85c8439561b0eff85bb9440a2e97a9
> And, here is the commit log:
> 
> author
> K. Y. Srinivasan <kys@microsoft.com> 2014-02-03 20:42:45 (GMT) 
> committer
> Greg Kroah-Hartman <gregkh@linuxfoundation.org> 2014-02-07 23:22:40 (GMT) 
> commit
> 8a7206a89f85c8439561b0eff85bb9440a2e97a9 (patch) 
> tree
> 61f763919607368481ac128f56416df1f49cd187 
> parent
> 011a7c3cc3aa60c7ea6bb49d847e80a299ba7b36 (diff) 
> 
> Drivers: hv: vmbus: Support per-channel driver state
> As we implement Virtual Receive Side Scaling on the networking side
> (the VRSS patches are currently under review), it will be useful to have
> per-channel state that vmbus drivers can manage. Add support for
> managing per-channel state.
> 
> KY:
> Do you know the original tree this patch was checked into by Greg KH? Or, 
> did Greg checked into linux-next tree directly?

No one "checks into the linux-next tree directly".

So your patch relies on a patch in my char-misc tree?  Ick, that wasn't
very wise.

It will just have to wait until the patch goes into 3.15-rc1, as my
trees are closed, sorry.

greg k-h
