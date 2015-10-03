From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH v2 1/3] unix: fix use-after-free in unix_dgram_poll()
Date: Sat, 03 Oct 2015 18:02:16 +0100
Message-ID: <87twq7ans7.fsf@doppelsaurus.mobileactivedefense.com>
References: <cover.1443817522.git.jbaron@akamai.com>
	<f4e283269e7063317956ea1de6fdc58449ee75cd.1443817522.git.jbaron@akamai.com>
	<CA+rthh9FMUHfaMcMXxJrsu+47xtQhG4ajmL_6rbJsAM1SRxGYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Baron <jbaron@akamai.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Eric Wong <normalperson@yhbt.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Davidlohr Bueso <dave@stgolabs.net>,
	Olivier Mauras <olivier@mauras.ch>,
	PaX Team <pageexec@freemail.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>
To: Mathias Krause <minipli@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+rthh9FMUHfaMcMXxJrsu+47xtQhG4ajmL_6rbJsAM1SRxGYw@mail.gmail.com>
	(Mathias Krause's message of "Sat, 3 Oct 2015 07:46:06 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mathias Krause <minipli@googlemail.com> writes:
> On 2 October 2015 at 22:43, Jason Baron <jbaron@akamai.com> wrote:
>> The unix_dgram_poll() routine calls sock_poll_wait() not only for the wait
>> queue associated with the socket s that we are poll'ing against, but also calls

[useless full-quote removed]

> My reproducer runs on this patch for more than 3 days now without
> triggering anything anymore.

Since the behaviour of your program is random, using it to "test"
anything doesn't really provide any insight: It could have been
executing the same codepath which doesn't happen to trigger any problems
for all of these three days. Nobody can tell.
