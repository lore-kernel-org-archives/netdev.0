From: Mike Fedyk <mfedyk@matchmail.com>
Subject: Re: Stale Filehandles was: [2.6] nfs_rename: target $file busy, d_count=2
Date: Fri, 16 Jan 2004 12:16:23 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116201623.GO1748@srv-lnx2600.matchmail.com>
References: <20040116050642.GF1748@srv-lnx2600.matchmail.com> <20040116130336.GA5220@oscar.prima.de> <20040116184031.GM1748@srv-lnx2600.matchmail.com> <20040116185504.GN1748@srv-lnx2600.matchmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick Mau <mau@oscar.ping.de>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040116185504.GN1748@srv-lnx2600.matchmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jan 16, 2004 at 10:55:04AM -0800, Mike Fedyk wrote:
> On Fri, Jan 16, 2004 at 10:40:31AM -0800, Mike Fedyk wrote:
> > I only had a few nfs clients doing light load, (kde home directories, and
> > such) and was able to reproduce stale nfs file handles just by running "find
> > > /dev/null" on the nfs share.
> > 
> > Have you tried the -mm tree recently?  2.6.1-mm4 even has some new nfsd
> > patches in there (maybe you should wait until -mm5 though, there are a few
> 
> Stale filehandles is the main problem right now, and I don't see how
> nfs_raname would be related (just that it was there while I was having
> trouble with the stale file handles...)
> 
> http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.1/2.6.1-mm4/broken-out/nfsd-01-stale-filehandles-fixes.patch
> 
> This one looks particularly interesting...
> 

Most of the nfs client patches are for NFS4 or RPCSEC_GSS.  Except for:

http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.1/2.6.1-mm4/broken-out/

nfs-26-sock_disconnect.patch
nfs-31-attr.patch
nfs-client-deadlock-fix.patch
nfs-fix-bogus-setattr-calls.patch
nfs-open-intent-fix.patch
nfs-optimise-COMMIT-calls.patch
nfs-readonly-mounts-fix.patch
nfs-rpc-debug-oops-fix.patch

These might be interesting to test, but so far I haven't had troubles with
the stock Linus 2.6 nfs3 client.

Mike
