From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take25 1/6] kevent: Description.
Date: Thu, 23 Nov 2006 11:45:36 -0800
Message-ID: <4565FA60.9000402@redhat.com>
References: <11641265982190@2ka.mipt.ru> <4564E162.8040901@redhat.com> <20061123115240.GA20294@2ka.mipt.ru>
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
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40401 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S933600AbWKWTqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Nov 2006 14:46:50 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061123115240.GA20294@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Kernel does not put there a new entry, it is only done inside
> kevent_wait(). Entries are put into queue (in any context), where the=
y can be obtained
> from only kevent_wait() or kevent_get_events().

I know this is how it's done now.  But it is not where it has to end.=20
IMO we have to get to a solution where new events are posted to the rin=
g=20
buffer asynchronously, i.e., without a thread calling kevent_wait.  And=
=20
then you need the extra parameter and verification.  Even if it's today=
=20
not needed we have to future-proof the interface since it cannot be=20
changed once in use.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
