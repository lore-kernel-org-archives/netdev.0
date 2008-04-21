From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH] [DCCP]: Convert do_gettimeofday() to getnstimeofday().
Date: Mon, 21 Apr 2008 10:48:44 -0300
Message-ID: <20080421134844.GC12221@ghostprotocols.net>
References: <20080421.162227.63020853.yoshfuji@linux-ipv6.org> <20080421.023503.242108516.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	dccp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42681 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753423AbYDUNsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 09:48:51 -0400
Content-Disposition: inline
In-Reply-To: <20080421.023503.242108516.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Apr 21, 2008 at 02:35:03AM -0700, David Miller escreveu:
> From: YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <yoshf=
uji@linux-ipv6.org>
> Date: Mon, 21 Apr 2008 16:22:27 +0900 (JST)
>=20
> > What do_gettimeofday() does is to call getnstimeofday() and
> > to convert the result from timespec{} to timeval{}.
> > We do not always need timeval{} and we can convert timespec{}
> > when we really need (to print).
> >=20
> > Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>=20
> This looks good too, but I'll be polite and wait for any
> DCCP maintainer ACKs :-)

Thanks everybody:

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

- Arnaldo
