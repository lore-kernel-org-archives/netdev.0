From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: Make ipconfig.c work as a loadable module.
Date: Fri, 7 Mar 2003 00:08:16 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030307000816.P838@flint.arm.linux.org.uk>
References: <Pine.LNX.4.44.0303061500310.31368-100000@mandrake.americas.sgi.com> <1046990052.18158.121.camel@irongate.swansea.linux.org.uk> <20030306221136.GB26732@gtf.org> <20030306222546.K838@flint.arm.linux.org.uk> <1046996037.18158.142.camel@irongate.swansea.linux.org.uk> <20030306231905.M838@flint.arm.linux.org.uk> <1046996987.17718.144.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Robin Holt <holt@sgi.com>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Content-Disposition: inline
In-Reply-To: <1046996987.17718.144.camel@irongate.swansea.linux.org.uk>; from alan@lxorguk.ukuu.org.uk on Fri, Mar 07, 2003 at 12:29:47AM +0000
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Mar 07, 2003 at 12:29:47AM +0000, Alan Cox wrote:
> On Thu, 2003-03-06 at 23:19, Russell King wrote:
> > "klibc doesnt really matter"
> > 
> > I'd prefer not to have to have thousands of special programs around
> > just to be able to boot my machines, especially when it was all in-
> > kernel up until this point.
> > 
> > klibc yes, dietlibc with random other garbage in some random filesystem
> > which'd need maintaining - no thanks.
> 
> You can build the dhcp client with glibc static into your initrd. Its hardly
> magic or special programs or random garbage, and last time I counted it came
> to one program. Dunno what the other 999 utilities your dhcp needs are ?

How about mount for nfs-root, a shell and a shell script to supply the
correct parameters to mount so it doesn't go and try to mount the
nfs-root with locking enabled - oh, and a few programs like sed and
so forth to pull the mount parameters out of the dhcp client output,
if there is such an output.

ipconfig.c does more than just configure networking.  It's a far smaller
solution to NFS-root than any userspace implementation could ever hope
to be.

-- 
Russell King (rmk@arm.linux.org.uk)                The developer of ARM Linux
             http://www.arm.linux.org.uk/personal/aboutme.html
