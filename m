From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Thu, 23 Nov 2006 15:23:36 +0300
Message-ID: <20061123122335.GE20294@2ka.mipt.ru>
References: <4560F07B.10608@redhat.com> <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru> <20061121184605.GA7787@2ka.mipt.ru> <4563FE71.4040807@redhat.com> <20061122104416.GD11480@2ka.mipt.ru> <4564BAC8.6020306@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Alexander Viro <aviro@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:30886 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S933617AbWKWM01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Nov 2006 07:26:27 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <4564BAC8.6020306@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 22, 2006 at 01:02:00PM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >But in this case it will be impossible to have SIGEV_THREAD and=20
> >SIGEV_KEVENT
> >at the same time, it will be just the same as SIGEV_SIGNAL but with
> >different delivery mechanism. Is is what you expect for that?
>=20
> Yes, that's expected.  The event if for the queue, not directed to a=20
> specific thread.
>=20
> If in future we want to think about preferably waking a specific thre=
ad=20
> we can then think about it.  But I doubt that'll be beneficial.  The=20
> thread specific part in the signal handling is only used to implement=
=20
> the SIGEV_THREAD notification.

Ok, so please review patch I sent, if it is ok from design point of
view, I will run some tests here.

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
