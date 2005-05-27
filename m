From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: A new driver for Broadcom bcm5706
Date: Fri, 27 May 2005 08:58:23 -0700
Message-ID: <1117209503.4584.11.camel@rh4>
References: <1116609329.31523.16.camel@rh4>
 <20050527074115.GA28208@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jgarzik@redhat.com, netdev@oss.sgi.com,
        ffan@broadcom.com, lusinsky@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Christoph Hellwig" <hch@infradead.org>
In-Reply-To: <20050527074115.GA28208@infradead.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-05-27 at 08:41 +0100, Christoph Hellwig wrote:
> On Fri, May 20, 2005 at 10:15:29AM -0700, Michael Chan wrote:
> > A new driver bnx2 for Broadcom bcm5706 is available. Since the patch is
> > over 500K, I've put it on the ftp server:
> > 
> > ftp://Net_sys_anon@ftp1.broadcom.com/bnx2-2.patch
> > 
> > The patch also includes new 1000BASE-X advertisement bit definitions in
> > mii.h
> 
> These defintions overlap older 10MB/s defintions.  I don't think the number
> space is scare enough to need this hack.  If we absolutely want to keep it
> you should at least add some big comments explaining it.
> 
> 
Yes they do. But these overlapping bit definitions are defined by the
802.3 standard for 1000Base-X. These are not Broadcom proprietary
definitions.
