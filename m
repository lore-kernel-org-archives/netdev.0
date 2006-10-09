From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [GIT PATCH] NET: Fixes for net-2.6.19
Date: Mon, 9 Oct 2006 09:08:12 -0700
Message-ID: <20061009090812.176533bf@freekitty>
References: <20060928155052.63ed5ce8@freekitty>
	<20060928.160458.00452499.davem@davemloft.net>
	<20060928162704.55e863ca@freekitty>
	<20060928.172827.26929236.davem@davemloft.net>
	<451C7E11.6040506@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	tgraf@suug.ch, netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:12501 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932983AbWJIRKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2006 13:10:05 -0400
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
In-Reply-To: <451C7E11.6040506@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 29 Sep 2006 10:59:45 +0900
Masahide NAKAMURA <nakam@linux-ipv6.org> wrote:

> David Miller wrote:
> >> commit 0844565fb8a9418f5a860aa480c1aef70319c9a2
> >> Author: Thomas Graf <tgraf@suug.ch>
> >> Date:   Fri Aug 4 23:05:56 2006 -0700
> >>
> >>     [NET]: Move netlink interface bits to linux/if.h
> >>     
> >>     Signed-off-by: Thomas Graf <tgraf@suug.ch>
> >>     Signed-off-by: David S. Miller <davem@davemloft.net>
> > 
> > Stephen, we just removed the troublesome bits from linux/if.h when I
> > put in Yoshifuji's patches last night, it should explicitly remove
> > this problem.
> > 
> > You will thus see that linux/rtnetlink.h no longer includes
> > linux/if.h, which is why your errors were completely perplexing
> > to me.  Instead, it includes linux/if_link.h
> > 
> > It's been in my tree since last night, and if you had used
> > the rtnetlink.h from my current tree you wouldn't have seen
> > the error.
> 
> Yes, as David mentioned you need to copy the latest rtnetlink.h
> at first. It is also required to be added if_{link,addr}.h, neighbour.h
> to iproute2 tree. Some macros may be needed for libnetlink.h, too.
> I'll send the patch to you if you haven't started on it.
> 
> Regards,
> 

Since the rtnetlink changes for 2.6.19, broke the GLIBC build, I am
going to wait until that gets straightened out first.

-- 
Stephen Hemminger <shemminger@osdl.org>
