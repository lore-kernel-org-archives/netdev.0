From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC,PATCH] fastroute dead code...
Date: Fri, 30 Jul 2004 17:11:03 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410AB967.2010202@pobox.com>
References: <20040730060348.GA22854@havoc.gtf.org>	 <ea86ce220407301229522be64f@mail.gmail.com>	 <20040730193515.GA11365@havoc.gtf.org>	 <20040730131004.2be1274d.davem@redhat.com> <1091219266.1029.470.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, tmattox@gmail.com,
        netdev@oss.sgi.com, Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1091219266.1029.470.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Fri, 2004-07-30 at 16:10, David S. Miller wrote:
>>I totally agree.  And people can always resurrect it from the
>>repository history or an old tarball if they wish.
> 
> 
> Patches are needed for the driver to use that code. So its not entirely
> dead code i.e it is referenced from fastroute enabled drivers.
> Sample (really old) code found at:
> http://ftp.iasi.roedu.net/mirrors/ftp.inr.ac.ru/ip-routing/fastroute/


Actually the opposite...  the driver infrastructure is pretty much in 
place.  It's the core IPv4 routing code that no longer does what people 
think :)

grep for RTCF_FAST in 2.4.x and then in 2.6.x...

	Jeff
