From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: Re: [GIT PULL net-next-2.6] IPv6 Updates
Date: Wed, 2 Jul 2008 19:59:34 +0900
Message-ID: <20080702195934.754349fb.mitch@linux.vnet.ibm.com>
References: <20080702.123957.75682669.yoshfuji@linux-ipv6.org>
	<486B2208.2000104@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki / =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Toyo Abe <tabe@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:52743 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755288AbYGBK7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 06:59:38 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m62Axb56021964
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 06:59:37 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m62AxbhK166552
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 04:59:37 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m62AxaGb032269
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 04:59:37 -0600
In-Reply-To: <486B2208.2000104@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Abe-san,

On Wed, 02 Jul 2008 15:36:56 +0900
Toyo Abe <tabe@miraclelinux.com> wrote:

> Hi,
> 
> I have a question regarding this one.
> 
> > commit e6a359e650a738f4e2387ca5570c546e03b7e29d
> > Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> > Date:   Sat Jun 28 14:18:38 2008 +0900
> > 
> >     ipv6 addrconf: add accept_dad sysctl to control DAD operation.
> >     
> >     - If 0, disable DAD.
> >     - If 1, perform DAD (default).
> >     - If >1, perform DAD and disable IPv6 operation if DAD for MAC-based
> >       link-local address has been failed (RFC4862 5.4.5).
> >     
> 
> I don't see why you set 1 as a default, so far.
> Any concerns on setting >1 as a default?

You may want to read this discussion:
- Linux IPv6 DAD not full conform to RFC 4862 ?
  http://www.spinics.net/lists/netdev/msg52027.html

The conclusion is:
  http://www.spinics.net/lists/netdev/msg52095.html

Best Regards,
----
Mitsuru Chinen <mitch@linux.vnet.ibm.com>


> Regards,
> -toyo
> 
> YOSHIFUJI Hideaki / 吉藤英明 wrote:
> > Hello.
> > 
> > Please consider pulling following changes on top of commit
> > 28f49d8fec19833672a6a813bfde0068fee50bc9
> >     Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/linville/wireless-next-2.6
> > available at
> >     git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-next.git net-next-2.6-v6ready-20080702
> > 
> > Regards,
> > 
> > --yoshfuji
> > 
> > HEADLINES
> > ---------
> > 
> >     ipv6: Do not assign non-valid address on interface.
> >     ipv6: Do not forward packets with the unspecified source address.
> >     ipv6: Assume the loopback address in link-local scope.
> >     ipv6: Add disable_ipv6 sysctl to disable IPv6 operaion on specific interface.
> >     ipv6 addrconf: add accept_dad sysctl to control DAD operation.
> >     ipv6 route: Prefer outgoing interface with source address assigned.
> > 
> > DIFFSTAT
> > --------
> > 
> >  Documentation/networking/ip-sysctl.txt |   11 +++++++
> >  include/linux/ipv6.h                   |    4 ++
> >  net/ipv6/addrconf.c                    |   53 ++++++++++++++++++++++++++++++++
> >  net/ipv6/ip6_input.c                   |    3 +-
> >  net/ipv6/ip6_output.c                  |   10 +++++-
> >  net/ipv6/route.c                       |   32 +++++++++++++------
> >  6 files changed, 101 insertions(+), 12 deletions(-)
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
