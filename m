From: Dawid Ciezarkiewicz <dpc@asn.pl>
Subject: Re: [RFC] wrr (weighted round-robin) bonding
Date: Fri, 20 Oct 2006 22:52:00 +0200
Message-ID: <200610202252.01390.dpc@asn.pl>
References: <200610162021.12884.dpc@asn.pl> <200610202141.15140.dpc@asn.pl> <200610201953.k9KJr2Zt000305@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from apollo.asn.pl ([85.14.104.1]:4997 "HELO apollo.asn.pl")
	by vger.kernel.org with SMTP id S1030259AbWJTUwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 16:52:20 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200610201953.k9KJr2Zt000305@death.nxdomain.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, 20 October 2006 21:53, Jay Vosburgh wrote:
> Dawid Ciezarkiewicz <dpc@asn.pl> wrote:
> 
> >On Thursday, 19 October 2006 21:04, Andy Gospodarek wrote:
> >> It would seem to me that extending an existing mode would be more
> >> desirable than adding yet another mode to worry about.  I don't even
> >> like the fact that there are as many as there are, but I understand why
> >> they are there.  
> >
> >Ack. I will probably update wrr bonding patch to replace rr mode.
> 
> 	Also, if acceptance into the mainline is your ultimate goal, the
> ioctl control interface will be a very difficult sell.  You'd want to
> look into some other control mechanism, most likely an additional sysfs
> entry.

Oh. I'm quite puzzled here. What is current policy? I'd like sysfs interfaces 
better than ioctl - they are much cleaner etc. - but I thought ioctl will be 
better here because current bonding control uses ioctl and extending it is 
much simpler.

More generally: should I use sysfs always when adding anything to kernel and 
use it even when extending older functionality?

If wrr bonding have chances for inclusion into mainline I'll do any necessary 
changes to let it meet requirements. I'd like to know if functionality from 
Andy's patch is desired to be a part of such round-robin bonding extension. I 
think I could easily integrate it with wrr.
