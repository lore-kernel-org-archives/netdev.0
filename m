From: malware@t-online.de (Michael Mueller)
Subject: Re: Make ipconfig.c work as a loadable module.
Date: Fri, 07 Mar 2003 08:15:20 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200303070715.IAA27138@fire.malware.de>
References: <Pine.LNX.4.44.0303061500310.31368-100000@mandrake.americas.sgi.com>
		 <1046990052.18158.121.camel@irongate.swansea.linux.org.uk>
		 <20030306221136.GB26732@gtf.org>
		 <20030306222546.K838@flint.arm.linux.org.uk>
		 <1046996037.18158.142.camel@irongate.swansea.linux.org.uk>
		 <20030306231905.M838@flint.arm.linux.org.uk> <1046996987.17718.144.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Russell King <rmk@arm.linux.org.uk>, Jeff Garzik <jgarzik@pobox.com>,
   Robin Holt <holt@sgi.com>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Alan,

you wrote:
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

Sorry, but I must join Russel here. I have atleast one machine which has
a bootloader able to load exactly one file only. There is currently no
way to load an initrd. It would need to implement the whole (BOOTP+)TFTP
stuff again, just to get the initrd. So I was quite happy linux 2.4
still knows about mounting a NFS root filesystem without user-space
help.


Michael
