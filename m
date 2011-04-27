From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Applying inappropriate ioctl operation on socket should
 return ENOTTY
Date: Wed, 27 Apr 2011 12:52:01 +0100
Message-ID: <20110427125201.18395e2f@lxorguk.ukuu.org.uk>
References: <1303882625-28115-1-git-send-email-lifongsun@gmail.com>
	<1303883910.2699.53.camel@edumazet-laptop>
	<20110427104738.2bdbe228@lxorguk.ukuu.org.uk>
	<1303901103.3166.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Lifeng Sun <lifongsun@gmail.com>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303901103.3166.30.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Well, I wont argue the point, especially if you Ack the changes ;)
> 
> My only concern was to not break old applications, I dont know if it is
> going to break _any_ of them. Probably these old applications stick with
> old kernels.

The number of applications that actually check ioctl error codes beyond
if error perror; return is pretty small and those that do generally do so
for very narrow cases or for things like EWOULDBLOCK/EINTR stuff.

> If you ask me ENOTTY is plain wrong.
> ioctl() is not restricted to terminal devices at all.

Like the tab/space thing in Makefiles and Qwerty keyboards its now part of
how stuff all works but EINVAL is even worse because you cannot tell
between 'this ioctl isn't know/is used on the wrong fd' and 'argument
wrong to valid ioctl'

Alan
