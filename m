From: Christoph Raisch <RAISCH@de.ibm.com>
Subject: Re: [2.6.19 PATCH 2/7] ehea: pHYP interface
Date: Fri, 18 Aug 2006 18:02:17 +0200
Message-ID: <OFF0CF1858.B1C22ED6-ONC12571CE.0056FB13-C12571CE.0057BEA6@de.ibm.com>
References: <20060818151340.GB27947@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>, netdev@vger.kernel.org,
	ossthema@de.ibm.com, Thomas Q Klein <tklein@de.ibm.com>,
	tklein@linux.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932474AbWHRP61@vger.kernel.org>
In-Reply-To: <20060818151340.GB27947@krispykreme>
To: Anton Blanchard <anton@samba.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>
> Hi,
>
> > I asked SO to recount arguments and we've come to a conclusion that
> > there're in fact 19 args not 18 as the name suggests. 19 args is
> > I-N-S-A-N-E.
>
> It will be partially cleaned up by:
>
> http://ozlabs.org/pipermail/linuxppc-dev/2006-July/024556.html
>
> However it doesnt fix the fact someone has architected such a crazy
> interface :(
>
> Anton


well, just as background info, this is the wrapper around
a single assembly instruction which calls system firmware and takes
9 CPU registers for input and 9 CPU registers for output parameters.
This definition by platform architecture won't change in the near future,
but the good news is with Antons change the wrapper will look much nicer.

Gruss / Regards . . . Christoph R
