From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Make ipconfig.c work as a loadable module.
Date: 07 Mar 2003 12:54:36 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1047041676.20793.12.camel@irongate.swansea.linux.org.uk>
References: <Pine.LNX.4.44.0303061500310.31368-100000@mandrake.americas.sgi.com>
	 <1046990052.18158.121.camel@irongate.swansea.linux.org.uk>
	 <20030306221136.GB26732@gtf.org>
	 <20030306222546.K838@flint.arm.linux.org.uk>
	 <1046996037.18158.142.camel@irongate.swansea.linux.org.uk>
	 <20030306231905.M838@flint.arm.linux.org.uk>
	 <1046996987.17718.144.camel@irongate.swansea.linux.org.uk>
	 <200303070715.IAA27138@fire.malware.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Russell King <rmk@arm.linux.org.uk>, Jeff Garzik <jgarzik@pobox.com>,
   Robin Holt <holt@sgi.com>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Mueller <malware@t-online.de>
In-Reply-To: <200303070715.IAA27138@fire.malware.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2003-03-07 at 07:15, Michael Mueller wrote:
> Hi Alan,
> Sorry, but I must join Russel here. I have atleast one machine which has
> a bootloader able to load exactly one file only. There is currently no
> way to load an initrd. It would need to implement the whole (BOOTP+)TFTP
> stuff again, just to get the initrd. So I was quite happy linux 2.4
> still knows about mounting a NFS root filesystem without user-space
> help.

Just glue the initrd to the kernel. This is not rocket science
