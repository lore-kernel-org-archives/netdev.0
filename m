From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take19 1/4] kevent: Core files.
Date: Sun, 15 Oct 2006 16:22:45 -0700
Message-ID: <4532C2C5.6080908@redhat.com>
References: <11587449471424@2ka.mipt.ru> <200610051245.03880.dada1@cosmosbay.com> <20061005105536.GA4838@2ka.mipt.ru> <200610051409.31826.dada1@cosmosbay.com> <20061005123715.GA7475@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Ulrich Drepper <drepper@gmail.com>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60904 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932144AbWJOXYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2006 19:24:22 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061005123715.GA7475@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Existing design does not allow overflow.

And I've pointed out a number of times that this is not practical at=20
best.  There are event sources which can create events which cannot be=20
coalesced into one single event as it would be required with your desig=
n.

Signals are one example, specifically realtime signals.  If we do not=20
want the design to be limited from the start this approach has to be=20
thought over.


>> So zap mmap() support completely, since it is not usable at all. We =
wont=20
>> discuss on it.
>=20
> Initial implementation did not have it.
> But I was requested to do it, and it is ready now.
> No one likes it, but no one provides an alternative implementation.
> We are stuck.

We need the mapped ring buffer.  The current design (before it was=20
removed) was broken but this does not mean it shouldn't be implemented.=
=20
  We just need more time to figure out how to implement it correctly.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
