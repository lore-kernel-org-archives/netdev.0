From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take25 1/6] kevent: Description.
Date: Fri, 24 Nov 2006 07:26:51 -0800
Message-ID: <45670F3B.2000503@redhat.com>
References: <11641265982190@2ka.mipt.ru>	<456621AC.7000009@redhat.com>	<45662522.9090101@garzik.org>	<45663298.7000108@redhat.com>	<45664160.6060504@cosmosbay.com> <20061124001412.371ec4e7.akpm@osdl.org> <4566AE48.70409@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jeff@garzik.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:10952 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S934840AbWKXP16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Nov 2006 10:27:58 -0500
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <4566AE48.70409@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Being able to direct a particular request on a particular CPU is=20
> certainly something that cannot be hardcoded in 'the new kevent inter=
face'.

Nobody is proposing this.  Although I have proposed that if the kernel=20
knows which CPU can best service a request it might hint as much.

But in general, you're free to decentralize as much as you want.  But=20
this does not mean it should not also be possible to use a number of=20
threads in the same loop and the same kevent queue.  That's the part=20
which needs designing, the separate queues will always be possible.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
