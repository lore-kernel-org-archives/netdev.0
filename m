From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] {selinux, af_key} Rework
 pfkey_sadb2xfrm_user_sec_ctx
Date: Thu, 17 Oct 2013 11:51:48 +0200
Message-ID: <20131017095148.GC7660@secunet.com>
References: <1381904114-29556-1-git-send-email-fan.du@windriver.com>
 <1541456.gnvYckRYYL@sifl>
 <525F3EBD.80406@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paul Moore <paul@paul-moore.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57905 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753798Ab3JQJvu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Oct 2013 05:51:50 -0400
Content-Disposition: inline
In-Reply-To: <525F3EBD.80406@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 17, 2013 at 09:34:53AM +0800, Fan Du wrote:
>=20
>=20
> On 2013=E5=B9=B410=E6=9C=8816=E6=97=A5 23:15, Paul Moore wrote:
> >
> >The fact that you are now changing sadb_x_sec_ctx->sadb_x_sec_len wh=
enever
> >pfkey_sadb2xfrm_user_sec_ctx() is called raises an eyebrow.  Can you=
 elaborate
> >on why this is not a problem?
> >
> Thanks for your attention, Paul.
>=20
> sadb_x_sec_ctx is extra headers passed down from user space, the usag=
e of
> of this data structure falls down to one of pfkey_funcs function only=
 for
> one time, more specifically speaking, it's only used by SELINUX for s=
ecurity
> checking for each operation. In other words, sadb_x_sec_ctx involves =
with a
> one shot business here. So the original codes seems do a lots of extr=
a job
> which could easily be avoid using casting operation.
>=20

Since the selinux people have to live with that change in the fist plac=
e,
I'd like to see an ack of one of the selinux maintainers before I take
in into ipsec-next, Paul?
