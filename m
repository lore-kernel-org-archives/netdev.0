From: Daniel Walker <dwalker@fifo99.com>
Subject: Re: AF_BUS socket address family
Date: Thu, 5 Jul 2012 09:01:54 -0700
Message-ID: <20120705160153.GA29175@fifo99.com>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
 <CAKnu2Mr_TWvBXmL+ORfddpEgPdPxPXFpJdCtvPe+imj6o6Y+1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vincent Sanders <vincent.sanders@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	John Stultz <john.stultz@linaro.org>,
	Anton Vorontsov <anton.vorontsov@linaro.org>,
	Greg Kroah-Hartman <greg@kroah.com>
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAKnu2Mr_TWvBXmL+ORfddpEgPdPxPXFpJdCtvPe+imj6o6Y+1w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 05, 2012 at 09:59:53AM +0200, Linus Walleij wrote:
> 2012/6/29 Vincent Sanders <vincent.sanders@collabora.co.uk>:
> 
> > AF_BUS is a message oriented inter process communication system.
> 
> We have a very huge and important in-kernel IPC message passer
> in drivers/staging/android/binder.c
> 
> It's deployed in some 400 million devices according to latest reports.
> John Stultz & Anton Vorontsov are trying to look after these Android
> drivers a bit...
> 
> I and others discussed this in the past with the Android folks. Dianne
> makes an excellent summary of how it works here:
> https://lkml.org/lkml/2009/6/25/3
> 
> If we could all be convinced that this thing also fulfills the needs
> of what binder does, this is a pretty solid case for it too. I can
> sure see that some of the shortcuts that Android is taking with
> binder try to address the same issue of high-speed IPC loopholes
> through the kernel and some kind of security model.
> 
> Whether Android would actually use it (or wrap it) is a totally
> different question, but what I think we need to know is whether it
> *could*. And staging code has to move forward, maybe this
> is the direction it should move?

I'm all for alternatives.. I haven't read this thread at all, but I read an LWN
article comparing Binder and other implementations .. So there are for sure
alternatives. It would be nice if things were included that did whatever binder
needs .. Since I did the logger performance analysis the big questions to me is
if Binder is actually fast (or faster than the alternatives). Whatever this
AF_BUS things is reviewing the performance of the major alternative(s) is probably a
good idea.

In terms of Android using anything we produce or incorporate, don't get
your hopes up .. They will always just use Binder .. (John is good cop, I'm bad
cop)

Daniel
