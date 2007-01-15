From: Li Yewang <lyw@nanjing-fnst.com>
Subject: Re: [patch]IPv6: fix BUG of ndisc_send_redirect()
Date: Mon, 15 Jan 2007 09:35:05 +0800
Message-ID: <45AADA49.6060800@nanjing-fnst.com>
References: <1168679560.3639.11.camel@localhost.localdomain> <20070114.231327.101009448.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:60027 "EHLO proxy.fnst.com.cn"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751776AbXAOBgQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Jan 2007 20:36:16 -0500
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <20070114.231327.101009448.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E says:

> It is not mandatory, however, it is better to do this.  I agree.
> (Note: In usual, we do not install gateway'ed route with global
> next-hop.)

   Yes, but if somebody set the route with global next-hop, or some
   other reasons, the next-hop with global address. The kernel must
   deal with this situation correctly. So, for the strongly of the
   kernel, I think redirect function must check the target address
   when send redirect packets.

> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>=20
> --yoshfuji
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
