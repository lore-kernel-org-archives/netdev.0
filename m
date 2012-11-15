From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] tunnel: use the correct endian for some fields
Date: Thu, 15 Nov 2012 09:57:38 +0100
Message-ID: <50A4AE82.3040602@6wind.com>
References: <1352969482-29836-1-git-send-email-amwang@redhat.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:62795 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992592Ab2KOI5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 03:57:42 -0500
Received: by mail-wg0-f44.google.com with SMTP id dr13so675736wgb.1
        for <netdev@vger.kernel.org>; Thu, 15 Nov 2012 00:57:41 -0800 (PST)
In-Reply-To: <1352969482-29836-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/11/2012 09:51, Cong Wang a =C3=A9crit :
> Fengguang reported:
>
> net/ipv6/ip6_tunnel.c:1571:33: sparse: incorrect type in assignment (=
different base types)
> net/ipv6/ip6_tunnel.c:1571:33:    expected restricted __be32 [usertyp=
e] flowinfo
> net/ipv6/ip6_tunnel.c:1571:33:    got unsigned int
>
> for these fields, we need to use the correct endian wrapers.
>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
Just one minute before my patch.
Your patch does not fix all warnings (i_flags & SIT_ISATAP in ip6_tunne=
l.c).
