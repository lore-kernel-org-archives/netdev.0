From: Mike Fedyk <mfedyk@matchmail.com>
Subject: [SOLVED] Stale Filehandles was: [2.6] nfs_rename: target $file busy, d_count=2
Date: Tue, 20 Jan 2004 12:12:12 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040120201212.GH23765@srv-lnx2600.matchmail.com>
References: <20040116050642.GF1748@srv-lnx2600.matchmail.com> <20040116130336.GA5220@oscar.prima.de> <20040116184031.GM1748@srv-lnx2600.matchmail.com> <20040116185504.GN1748@srv-lnx2600.matchmail.com> <20040117184716.GX1748@srv-lnx2600.matchmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick Mau <mau@oscar.ping.de>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040117184716.GX1748@srv-lnx2600.matchmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jan 17, 2004 at 10:47:16AM -0800, Mike Fedyk wrote:
> On Fri, Jan 16, 2004 at 10:55:04AM -0800, Mike Fedyk wrote:
> > On Fri, Jan 16, 2004 at 10:40:31AM -0800, Mike Fedyk wrote:
> > > I only had a few nfs clients doing light load, (kde home directories, and
> > > such) and was able to reproduce stale nfs file handles just by running "find
> > > > /dev/null" on the nfs share.
> > > 
> > > Have you tried the -mm tree recently?  2.6.1-mm4 even has some new nfsd
> > > patches in there (maybe you should wait until -mm5 though, there are a few
> > 
> > Stale filehandles is the main problem right now, and I don't see how
> > nfs_raname would be related (just that it was there while I was having
> > trouble with the stale file handles...)
> > 
> > http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.1/2.6.1-mm4/broken-out/nfsd-01-stale-filehandles-fixes.patch
> > 
> > This one looks particularly interesting...
> > 
> 
> I'm running 2.6.1-bk2-nfs-stale-file-handles on my nfsd server now, and so
> far I haven't seen any stale filehandles.
> 
> Can you guys patch stock 2.6.1 with the above and test also so we can get
> more breadth in the testing results?
> 

Well, it's been running since friday with the same load that killed it in
less than a day, so I'm happy.

And BTW, the code has been merged by Linus and is in 2.6.1-bk6.

Mike
