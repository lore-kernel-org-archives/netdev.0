From: Dan Williams <dcbw@redhat.com>
Subject: Re: [RFC PATCH] bridge: remove !IFF_UP restriction when deleting
 bridge from ioctl
Date: Fri, 04 Apr 2014 10:15:50 -0500
Message-ID: <1396624550.15118.11.camel@dcbw.local>
References: <1396623382.15118.6.camel@dcbw.local>
	 <20140404.110800.1665495271585798396.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42941 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753113AbaDDPPi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2014 11:15:38 -0400
In-Reply-To: <20140404.110800.1665495271585798396.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-04-04 at 11:08 -0400, David Miller wrote:
> From: Dan Williams <dcbw@redhat.com>
> Date: Fri, 04 Apr 2014 09:56:22 -0500
> 
> > netlink doesn't care about IFF_UP when deleting a bridge, so "ip link
> > del br0" works just fine.  The ioctl does care, which means that brctl
> > complains "bridge br0 still up; can't delete it".  Make things
> > consistent by always allowing bridge deletion even if the bridge is up.
> > 
> > Signed-off-by: Dan Williams <dcbw@redhat.com>
> > ---
> > Question: does anyone consider the ioctl behavior API?  Can we change it
> > even though it's been this way forever?  It means that bridges that
> > previously would not have been deleted by brctl will now be deleted.
> > But anyone using /sbin/ip could already delete them.
> 
> Unfortunately I think we're stuck with the existing behavior.

Ok, fair enough.

Dan
