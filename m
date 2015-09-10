From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net v2 0/2] xen-net{front,back}: respect user provided
 max_queues
Date: Thu, 10 Sep 2015 10:05:03 +0100
Message-ID: <20150910090503.GA29711@zion.uk.xensource.com>
References: <1441794186-26991-1-git-send-email-wei.liu2@citrix.com>
 <20150909.215322.1247922588988536450.davem@davemloft.net>
 <20150909.220553.642261089490536395.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:25312 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751227AbbIJJFG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2015 05:05:06 -0400
Content-Disposition: inline
In-Reply-To: <20150909.220553.642261089490536395.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 09, 2015 at 10:05:53PM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 09 Sep 2015 21:53:22 -0700 (PDT)
>=20
> > From: Wei Liu <wei.liu2@citrix.com>
> > Date: Wed, 9 Sep 2015 11:23:04 +0100
> >=20
> >> Wei Liu (2):
> >>   xen-netback: respect user provided max_queues
> >>   xen-netfront: respect user provided max_queues
> >=20
> > Both applied, thanks.
>=20
> Yo, this doesn't even compile!
>=20
> drivers/net/xen-netfront.c: In function =E2=80=98netif_init=E2=80=99:
> drivers/net/xen-netfront.c:2138:6: error: =E2=80=98xenvif_max_queues=E2=
=80=99 undeclared (first use in this function)
>   if (xenvif_max_queues =3D=3D 0)
>       ^
> drivers/net/xen-netfront.c:2138:6: note: each undeclared identifier i=
s reported only once for each function it appears in
>=20

Sorry about this.

I will send an updated version.

Wei.
