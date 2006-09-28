From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PATCH] NET: Fixes for net-2.6.19
Date: Thu, 28 Sep 2006 16:04:58 -0700 (PDT)
Message-ID: <20060928.160458.00452499.davem@davemloft.net>
References: <20060928083645.786b1ab1@freekitty>
	<20060928.143304.83622307.davem@davemloft.net>
	<20060928155052.63ed5ce8@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, tgraf@suug.ch, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:10633
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751027AbWI1XE4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 19:04:56 -0400
To: shemminger@osdl.org
In-Reply-To: <20060928155052.63ed5ce8@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 28 Sep 2006 15:50:52 -0700

> On Thu, 28 Sep 2006 14:33:04 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Stephen Hemminger <shemminger@osdl.org>
> > Date: Thu, 28 Sep 2006 08:36:45 -0700
> > 
> > > Please figure out how to keep rtnetlink.h useful from user space.
> > > I tried putting the current sanitized version of rtnetlink.h into
> > > iproute2 and the build fails. 
> > 
> > Please give the error so I have a chance of fixing this.
> 
> If I put 2.6.19 headers in:
> 
> 
> In file included from ../include/linux/rtnetlink.h:5,
>                  from ../include/libnetlink.h:6,
>                  from ll_map.c:23:
> /usr/include/linux/if.h:117: error: redefinition of $,1rx(Bstruct ifmap$,1ry(B
> /usr/include/linux/if.h:153: error: redefinition of $,1rx(Bstruct ifreq$,1ry(B
> /usr/include/linux/if.h:203: error: redefinition of $,1rx(Bstruct ifconf$,1ry(B

Hmmm... we explicitly removed the "linux/if.h" inclusion from
rtnetlink.h so this is weird.  Where is the linux/if.h include coming
from?

