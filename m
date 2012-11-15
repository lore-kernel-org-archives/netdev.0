From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next] tunnel: use the correct endian for some fields
Date: Thu, 15 Nov 2012 17:04:35 +0800
Message-ID: <1352970275.31884.37.camel@cr0>
References: <1352969482-29836-1-git-send-email-amwang@redhat.com>
	 <50A4AE82.3040602@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54869 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754505Ab2KOJEm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 04:04:42 -0500
In-Reply-To: <50A4AE82.3040602@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-15 at 09:57 +0100, Nicolas Dichtel wrote:
> Le 15/11/2012 09:51, Cong Wang a =C3=A9crit :
> > Fengguang reported:
> >
> > net/ipv6/ip6_tunnel.c:1571:33: sparse: incorrect type in assignment=
 (different base types)
> > net/ipv6/ip6_tunnel.c:1571:33:    expected restricted __be32 [usert=
ype] flowinfo
> > net/ipv6/ip6_tunnel.c:1571:33:    got unsigned int
> >
> > for these fields, we need to use the correct endian wrapers.
> >
> > Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> > Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> > Cc: David S. Miller <davem@davemloft.net>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> Just one minute before my patch.
> Your patch does not fix all warnings (i_flags & SIT_ISATAP in ip6_tun=
nel.c).

Yeah, then ignore this patch. :)
