From: Christoph Hellwig <hch@infradead.org>
Subject: Re: A new driver for Broadcom bcm5706
Date: Fri, 27 May 2005 08:41:15 +0100
Message-ID: <20050527074115.GA28208@infradead.org>
References: <1116609329.31523.16.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jgarzik@redhat.com, netdev@oss.sgi.com,
        ffan@broadcom.com, lusinsky@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1116609329.31523.16.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, May 20, 2005 at 10:15:29AM -0700, Michael Chan wrote:
> A new driver bnx2 for Broadcom bcm5706 is available. Since the patch is
> over 500K, I've put it on the ftp server:
> 
> ftp://Net_sys_anon@ftp1.broadcom.com/bnx2-2.patch
> 
> The patch also includes new 1000BASE-X advertisement bit definitions in
> mii.h

These defintions overlap older 10MB/s defintions.  I don't think the number
space is scare enough to need this hack.  If we absolutely want to keep it
you should at least add some big comments explaining it.
