From: Christoph Hellwig <hch@lst.de>
Subject: Re: Bug#267342: kernel-image-2.6.8-1-686-smp: TCP/IP strangeness in 2.6.8
Date: Wed, 25 Aug 2004 16:48:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040825144808.GA10396@lst.de>
References: <20040822021929.E9D04212D@maus.private.neotoma.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kristine Diana Daniels <kddaniel@private.neotoma.org>,
        267342@bugs.debian.org
Content-Disposition: inline
In-Reply-To: <20040822021929.E9D04212D@maus.private.neotoma.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Could it be possible OpenBSD doesn't properly deal with the tcp window
scaling changes in 2.6.8? (http://lwn.net/Articles/92727/)


On Sat, Aug 21, 2004 at 10:19:29PM -0400, Kristine Diana Daniels wrote:
> Package: kernel-image-2.6.8-1-686-smp
> Version: 2.6.8-1
> Severity: important
> 
> I have noticed strangeness with the 2.6.8 kernel on both 686-smp
> and k7.
> 1) rsync from 2.6.8 to a 2.6.7 host hangs.
> 2) ssh from 2.6.8 to a 2.6.7 host hangs.
> 3) nntp from 2.6.8 hangs for 52 seconds before proceeding.
> 4) ssh from Openbsd to 2.6.8 hangs after SSH2_MSG_KEX_DH_GEX_REQUEST
> 
> In 1-2 the network topology is as follows
> 2.6.8host <-ethernet-> OpenBSD <-openvpn-> OpenBSD <-ethernet-> 2.6.7host
> In 3 the network topology is as follows
> 2.6.8host <-ethernet-> OpenBSD <-openvpn-> OpenBSD <-internet-> nntp-server
> In 4 the network topology is as follows
> 2.6.8host <-ethernet-> OpenBSD
> 
> In all instances OpenBSD is OpenBSD 3.5+Security updates from up to July.
> The problem does not exhibit itsself with 2.6.7.
> 
> Attached are tcpdumps taken from openbsd and linux for both 2.6.7 and 2.6.8
> of the conversation for nntp.
> tcpdumps for the ssh transactions are available upon request.
> Snapshot of /proc/sys/net/ipv4 also available upon request.
> 
> -- System Information:
> Debian Release: 3.1
>   APT prefers unstable
>   APT policy: (500, 'unstable'), (500, 'testing')
> Architecture: i386 (i686)
> Kernel: Linux 2.6.8-1-686-smp
> Locale: LANG=en_US, LC_CTYPE=en_US
> 
> Versions of packages kernel-image-2.6.8-1-686-smp depends on:
> ii  coreutils [fileutils]         5.2.1-2    The GNU core utilities
> ii  fileutils                     5.2.1-2    The GNU file management utilities 
> ii  initrd-tools                  0.1.73     tools to create initrd image for p
> ii  module-init-tools             3.1-pre5-6 tools for managing Linux kernel mo
> 
> -- no debconf information
