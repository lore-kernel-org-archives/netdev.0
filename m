From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Make ipconfig.c work as a loadable module.
Date: 07 Mar 2003 00:29:47 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1046996987.17718.144.camel@irongate.swansea.linux.org.uk>
References: <Pine.LNX.4.44.0303061500310.31368-100000@mandrake.americas.sgi.com>
	 <1046990052.18158.121.camel@irongate.swansea.linux.org.uk>
	 <20030306221136.GB26732@gtf.org>
	 <20030306222546.K838@flint.arm.linux.org.uk>
	 <1046996037.18158.142.camel@irongate.swansea.linux.org.uk>
	 <20030306231905.M838@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Robin Holt <holt@sgi.com>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Russell King <rmk@arm.linux.org.uk>
In-Reply-To: <20030306231905.M838@flint.arm.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-03-06 at 23:19, Russell King wrote:
> "klibc doesnt really matter"
> 
> I'd prefer not to have to have thousands of special programs around
> just to be able to boot my machines, especially when it was all in-
> kernel up until this point.
> 
> klibc yes, dietlibc with random other garbage in some random filesystem
> which'd need maintaining - no thanks.

You can build the dhcp client with glibc static into your initrd. Its hardly
magic or special programs or random garbage, and last time I counted it came
to one program. Dunno what the other 999 utilities your dhcp needs are ?
