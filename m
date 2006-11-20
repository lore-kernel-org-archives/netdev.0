From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Mon, 20 Nov 2006 13:52:44 -0800
Message-ID: <456223AC.5080400@redhat.com>
References: <11630606361046@2ka.mipt.ru> <45564EA5.6020607@redhat.com> <20061113105458.GA8182@2ka.mipt.ru> <4560F07B.10608@redhat.com> <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <45622228.80803@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Alexander Viro <aviro@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:986 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S966737AbWKTVzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 16:55:25 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45622228.80803@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> I think we have lived with relative timeouts for so long, it would be=
=20
> unusual to change now.  select(2), poll(2), epoll_wait(2) all take=20
> relative timeouts.

I'm not talking about always using absolute timeouts.

I'm saying the timeout parameter should be a struct timespec* and then=20
the flags word could have a flag meaning "this is an absolute timeout".=
=20
  I.e., enable both uses,, even make relative timeouts the default.=20
This is what the modern POSIX interfaces do, too, see clock_nanosleep.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
