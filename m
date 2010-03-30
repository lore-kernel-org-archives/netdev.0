From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] ethtool: RXHASH flag support
Date: Tue, 30 Mar 2010 14:31:33 -0700
Message-ID: <20100330143133.709f542b@nehalam>
References: <20100328154448.701c89ee@nehalam>
	<20100329174727.4654e19c@nehalam>
	<20100329175352.38008e05@nehalam>
	<4BB234DD.9040800@garzik.org>
	<20100330103207.7fc5681a@nehalam>
	<4BB236C9.7080300@garzik.org>
	<20100330140519.7b45cbb6@nehalam>
	<4BB26860.2040000@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45194 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752272Ab0C3Vbq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 17:31:46 -0400
In-Reply-To: <4BB26860.2040000@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Mar 2010 17:08:48 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> On 03/30/2010 05:05 PM, Stephen Hemminger wrote:
> > On Tue, 30 Mar 2010 13:37:13 -0400
> > Jeff Garzik<jeff@garzik.org>  wrote:
> >
> >> On 03/30/2010 01:32 PM, Stephen Hemminger wrote:
> >>> On Tue, 30 Mar 2010 13:29:01 -0400
> >>> Jeff Garzik<jeff@garzik.org>   wrote:
> >>>
> >>>> By blindly sync'ing the ethtool.h header, ETHTOOL_MAX_NTUPLE_LIST_ENTRY
> >>>> and its sibling ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY were removed,
> >>>> breaking the ethtool build.
> >>>
> >>> In the patch I moved it to ethtool.c to have local entries.
> >>>
> >>> I believe that all cloned headers should only come from the result
> >>> of kernel "make install_headers".  Not locally different vrsions.
> >>
> >> There is nothing locally different about ethtool-copy.h.
> >>
> >> 	Jeff
> >
> > diff -u ethtool-copy.h ~/kernel/net-next-2.6/usr/include/linux/ethtool.h
> > --- ethtool-copy.h	2010-03-30 14:03:45.000000000 -0700
> > +++ /home/shemminger/kernel/net-next-2.6/usr/include/linux/ethtool.h	2010-03-30 14:04:30.893866057 -0700
> 
> The canonical copy of ethtool-copy.h comes from the kernel tree's 
> include/linux/ethtool.h.
> 

The difference comes because scripts/headers_install.pl decides to change inline to __inline__.
I think Kbuild is the proper place to do any exported headers cleanup, so I would
rather the automated process work.


-- 
