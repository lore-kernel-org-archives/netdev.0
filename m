From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: Use-after-free in ppoll
Date: Sun, 22 Nov 2015 18:51:44 +0000
Message-ID: <87vb8tq33z.fsf@doppelsaurus.mobileactivedefense.com>
References: <CACT4Y+YRbhn+vUZqb9zY0X3fw_VSc_Ab5JKiEa5L-0g4U9zoSA@mail.gmail.com>
	<8737vym7f3.fsf@doppelsaurus.mobileactivedefense.com>
	<CACT4Y+YuBQH2tYt3hqCd6f5yR7iQcU6prf0VGPUoBxv6yCpJ7w@mail.gmail.com>
	<87ziy5q3cy.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Jason Baron <jbaron@akamai.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	David Howells <dhowells@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87ziy5q3cy.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Sun, 22 Nov 2015 18:46:21 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rainer Weikusat <rweikusat@mobileactivedefense.com> writes:

[...]


> because of the close, this routine will be called with the peer_wait
> wait_queue_head of the non-closed socket of the socket pair as
> wait_address argument.

This should have been "peer_wait wait_queue_head of the peer of the
non-closed socket, ie, that of the closed socket"...
