From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v4 3/3] net: reserve ports for applications
 using fixed port numbers
Date: Wed, 17 Feb 2010 17:39:28 +0100
Message-ID: <1266424768.3075.61.camel@edumazet-laptop>
References: <1266271241-6293-1-git-send-email-opurdila@ixiacom.com>
	 <1266271241-6293-4-git-send-email-opurdila@ixiacom.com>
	 <4B7A6740.1000701@redhat.com> <201002161306.29708.opurdila@ixiacom.com>
	 <4B7A9852.5020105@redhat.com> <1266326425.3045.53.camel@edumazet-laptop>
	 <4B7C159A.3060603@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B7C159A.3060603@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 18 f=C3=A9vrier 2010 =C3=A0 00:13 +0800, Cong Wang a =C3=A9cri=
t :

> I don't think so, if you want to avoid race condition, you just need =
to
> write the reserved ports before any networking application starts, IO=
W,
> as early as possible during boot.
>=20

Sure, but I was thinking retrieving the list of reserved port by a
database query, using network :)

Anyway, I just feel your argument is not applicable.

Our kernel is capable of doing an intersection for us, we dont need
to forbid user to mark a port as 'reserved' if this port is already
blacklisted by another mechanism (for example, if this port is already
in use)
