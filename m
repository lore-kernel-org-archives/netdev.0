From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: Wed, 23 Aug 2006 10:56:59 +0400
Message-ID: <20060823065659.GC24787@2ka.mipt.ru>
References: <b3f268590608221551q5e6a1057hd1474ee8b9811f10@mail.gmail.com> <20060822231129.GA18296@ms2.inr.ac.ru> <b3f268590608221728r6cffd03i2f2dd12421b9f37@mail.gmail.com> <20060822.173200.126578369.davem@davemloft.net> <b3f268590608221743o493080d0t41349bc4336bdd0b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	nmiell@comcast.net, linux-kernel@vger.kernel.org,
	drepper@redhat.com, akpm@osdl.org, netdev@vger.kernel.org,
	zach.brown@oracle.com, hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:2276 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751431AbWHWG6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 02:58:18 -0400
To: Jari Sundell <sundell.software@gmail.com>
Content-Disposition: inline
In-Reply-To: <b3f268590608221743o493080d0t41349bc4336bdd0b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 23, 2006 at 02:43:50AM +0200, Jari Sundell (sundell.software@gmail.com) wrote:
> Actually, I didn't miss that, it is an orthogonal issue. A timespec
> timeout parameter for the syscall does not imply the use of timespec
> in any timer event, etc. Nor is there any timespec timer in kqueue's
> struct kevent, which is the only (interface related) thing that will
> be exposed.

void * in structure exported to userspace is forbidden.
long in syscall requires wrapper in per-arch code (although that
workaround _is_ there, it does not mean that broken interface should 
be used).
poll uses millisecods - it is perfectly ok.

> Rakshasa

-- 
	Evgeniy Polyakov
