From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] epoll: add EPOLLEXCLUSIVE support
Date: Tue, 14 Feb 2012 22:06:15 +0100
Message-ID: <1329253575.2555.16.camel@edumazet-laptop>
References: <1329252484-6309-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Davide Libenzi <davidel@xmailserver.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329252484-6309-1-git-send-email-hagen@jauu.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 14 f=C3=A9vrier 2012 =C3=A0 21:48 +0100, Hagen Paul Pfeifer a =
=C3=A9crit :
> High performance server sometimes create one listening socket (e.g. p=
ort
> 80), create a epoll file descriptor and add the socket. Afterwards
> create SC_NPROCESSORS_ONLN threads and wait for events. This often
> result in a thundering herd problem because all CPUs are scheduled.
>=20
> This patch add an additional flag to epoll_ctl(2) called EPOLLEXCLUSI=
VE.
> If a descriptor is added with this flag only one CPU is scheduled in.
>=20
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
> Reported-by: Li Yu <raise.sail@gmail.com>
> Cc: Davide Libenzi <davidel@xmailserver.org>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> ---

Seems pretty good to me.

Do you have some performance numbers to share ?
