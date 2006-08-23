From: "Jari Sundell" <sundell.software@gmail.com>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: Wed, 23 Aug 2006 02:43:50 +0200
Message-ID: <b3f268590608221743o493080d0t41349bc4336bdd0b@mail.gmail.com>
References: <b3f268590608221551q5e6a1057hd1474ee8b9811f10@mail.gmail.com>
	 <20060822231129.GA18296@ms2.inr.ac.ru>
	 <b3f268590608221728r6cffd03i2f2dd12421b9f37@mail.gmail.com>
	 <20060822.173200.126578369.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, johnpol@2ka.mipt.ru, nmiell@comcast.net,
	linux-kernel@vger.kernel.org, drepper@redhat.com, akpm@osdl.org,
	netdev@vger.kernel.org, zach.brown@oracle.com, hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.193]:50805 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S932099AbWHWAnv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 20:43:51 -0400
Received: by nz-out-0102.google.com with SMTP id 14so630404nzn
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2006 17:43:51 -0700 (PDT)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060822.173200.126578369.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/23/06, David Miller <davem@davemloft.net> wrote:
> > There are system calls that take timespec, so I assume the magic is
> > already available for handling the timeout argument of kevent.
>
> System calls are one thing, they can be translated for these
> kinds of situations.  But this doesn't help, and nothing at
> all can be done, for datastructures exposed to userspace via
> mmap()'d buffers, which is what kevent will be doing.
>
> This is what Alexey is trying to explain to you.

Actually, I didn't miss that, it is an orthogonal issue. A timespec
timeout parameter for the syscall does not imply the use of timespec
in any timer event, etc. Nor is there any timespec timer in kqueue's
struct kevent, which is the only (interface related) thing that will
be exposed.

Rakshasa
