From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Mon, 27 Nov 2006 10:23:39 -0800
Message-ID: <456B2D2B.9080502@redhat.com>
References: <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru> <4563FD53.7030307@redhat.com> <20061122120933.GA32681@2ka.mipt.ru> <20061122121516.GA7229@2ka.mipt.ru> <4564CE00.9030904@redhat.com> <20061123122225.GD20294@2ka.mipt.ru> <456605EA.5060601@redhat.com> <20061124105856.GE13600@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
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
Received: from mx1.redhat.com ([66.187.233.31]:14741 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1758516AbWK0SYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 13:24:05 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061124105856.GE13600@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
>=20
> With provided patch it is possible to wakeup 'for-free' - just call
> kevent_ctl(ready) with zero number of ready events, so thread will be
> awakened if it was in poll(kevent_fd), kevent_wait() or
> kevent_get_events().

Yes, I realize that.  But I wrote something else:

 >> Rather than mark an existing entry as ready, how about a call to
 >> inject a new ready event?
 >>
 >> This would be useful to implement functionality at userlevel and
 >> still use an event queue to announce the availability.  Without thi=
s
 >> type of functionality we'd need to use indirect notification via
 >> signal or pipe or something like that.

This is still something which is wanted.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
