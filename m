From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: Make ipconfig.c work as a loadable module.
Date: Fri, 07 Mar 2003 17:00:15 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E69166F.9080604@nortelnetworks.com>
References: <Pine.LNX.4.44.0303061500310.31368-100000@mandrake.americas.sgi.com> <1046990052.18158.121.camel@irongate.swansea.linux.org.uk> <20030306221136.GB26732@gtf.org> <20030306222546.K838@flint.arm.linux.org.uk> <1046996037.18158.142.camel@irongate.swansea.linux.org.uk> <20030306231905.M838@flint.arm.linux.org.uk> <1046996987.17718.144.camel@irongate.swansea.linux.org.uk> <20030307000816.P838@flint.arm.linux.org.uk> <20030307012905.G20725@parcelfarce.linux.theplanet.co.uk> <20030307094235.A11807@flint.arm.linux.org.uk> <20030307214749.GA20188@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Dukes <pakrat@www.uk.linux.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>,
   Jeff Garzik <jgarzik@pobox.com>, Robin Holt <holt@sgi.com>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: William Lee Irwin III <wli@holomorphy.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

William Lee Irwin III wrote:
> On Fri, Mar 07, 2003 at 09:42:35AM +0000, Russell King wrote:
> 
>>That's getting on for 2MB vs:
>>   2620    2012       0    4632    1218 fs/nfs/nfsroot.o
>>   8016     380      80    8476    211c net/ipv4/ipconfig.o
>>about 13K.
>>
> 
> There's a cap on the maximum size of things various bootloaders can
> load via tftp; 2MB is relatively certain to blow it. ISTR the limit
> being something near 1MB for 2 of my boxen.

Since this is totally machine/architecture specific (we're tftp'ing 10MB 
kernel/ramdisk images to embedded PPC machines here) it might be a good 
idea to ask around and find what the most restrictive requirements are. 
  Is 1MB the worst-case or does it get even tighter?

Chris



-- 
Chris Friesen                    | MailStop: 043/33/F10
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
