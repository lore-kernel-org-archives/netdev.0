From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take25 1/6] kevent: Description.
Date: Tue, 28 Nov 2006 13:26:49 +0300
Message-ID: <20061128102649.GF15083@2ka.mipt.ru>
References: <11641265982190@2ka.mipt.ru> <456621AC.7000009@redhat.com> <20061124120531.GC32545@2ka.mipt.ru> <456B3FF2.3010908@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:62899 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S935813AbWK1K2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 05:28:12 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <456B3FF2.3010908@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 27, 2006 at 11:43:46AM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >It _IS_ how previous interface worked.
> >
> >	EXACTLY!
>=20
> No, the old interface committed everything not only up to a given ind=
ex.=20
>  This is the huge difference which makes or breaks it.

Interface was the same - logic behind it was differnet, the only thing
required was to add consumer's index - that is all, no need to change a
lot of declarations, userspace and so on - just use existing interface
and extend its functionality.=20

But it does not matter anymore, later this week I will collect all
proposed changes and implement (hopefully) last release, which will
close most of the questions regarding userspace interfaces (except
signal mask, it is in fluent state), so we could concentrate on
internals and/or new kernel users.

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
