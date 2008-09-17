From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH 04/14] Phonet: PF_PHONET protocol family support
Date: Wed, 17 Sep 2008 13:48:56 +0300
Message-ID: <200809171348.56427.remi.denis-courmont@nokia.com>
References: <200809161757.38571.remi.denis-courmont@nokia.com> <1221577694-4513-4-git-send-email-remi.denis-courmont@nokia.com> <20080916161747.GH8702@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "ext Arnaldo Carvalho de Melo" <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:35094 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbYIQKtc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2008 06:49:32 -0400
In-Reply-To: <20080916161747.GH8702@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tuesday 16 September 2008 19:17:47 ext Arnaldo Carvalho de Melo, you=
 wrote:
> > +/* Protocols in Phonet protocol family. */
> > +struct phonet_protocol {
> > +	struct proto		*prot;
> > +	int			sock_type;
> > +};
>
> Without looking in detail, first reaction is: don't we have sk_type i=
n
> struct sock? Can't it be used or what you would have in
> ponet_protocol->sock_type be mapped to it?

I would need to have the socket type into struct proto, not in struct s=
ock.
Other families have this "problem" as well (at least inet...).

However, I assume some transport protocols support more than one socket=
 types,=20
such that it is not possible to add a socket type to struct proto, righ=
t?

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
