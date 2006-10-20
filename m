From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [RFC] wrr (weighted round-robin) bonding
Date: Fri, 20 Oct 2006 17:35:55 -0400
Message-ID: <20061020213555.GA25860@gospo.rdu.redhat.com>
References: <200610162021.12884.dpc@asn.pl> <200610202141.15140.dpc@asn.pl> <200610201953.k9KJr2Zt000305@death.nxdomain.ibm.com> <200610202252.01390.dpc@asn.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60058 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1030205AbWJTVhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:37:20 -0400
To: Dawid Ciezarkiewicz <dpc@asn.pl>
Content-Disposition: inline
In-Reply-To: <200610202252.01390.dpc@asn.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 20, 2006 at 10:52:00PM +0200, Dawid Ciezarkiewicz wrote:
> 
> Oh. I'm quite puzzled here. What is current policy? I'd like sysfs interfaces 
> better than ioctl - they are much cleaner etc. - but I thought ioctl will be 
> better here because current bonding control uses ioctl and extending it is 
> much simpler.

I can't tell you for sure if there is a 'policy' about this, but I would
encourage you to focus energy on sysfs rather than the ioctl interface.
In the future I would guess more will begin to use sysfs rather than
ifenslave.


