From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Make ipconfig.c work as a loadable module.
Date: Thu, 6 Mar 2003 17:11:36 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030306221136.GB26732@gtf.org>
References: <Pine.LNX.4.44.0303061500310.31368-100000@mandrake.americas.sgi.com> <1046990052.18158.121.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robin Holt <holt@sgi.com>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Content-Disposition: inline
In-Reply-To: <1046990052.18158.121.camel@irongate.swansea.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 06, 2003 at 10:34:16PM +0000, Alan Cox wrote:
> On Thu, 2003-03-06 at 21:10, Robin Holt wrote:
> > The patch at the end of this email makes ipconfig.c work as a loadable 
> > module under the 2.5.  The diff was taken against the bitkeeper tree 
> > changeset 1.1075.
> 
> The right fix is to delete ipconfig.c, it has been the right fix for a long
> long time. There are initrd based bootp/dhcp setups that can also then mount
> a root NFS partition and they do *not* need any kernel helper.

The klibc tarball on kernel.org also has ipconfig-type code, waiting for
initramfs early userspace :)

Many have wanted to delete ipconfig.c for a while now...

	Jeff
