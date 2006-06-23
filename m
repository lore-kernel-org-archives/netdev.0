From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] Kevent subsystem.
Date: Fri, 23 Jun 2006 09:50:23 +0400
Message-ID: <20060623055019.GA7771@2ka.mipt.ru>
References: <20060622171436.GA26161@2ka.mipt.ru> <7e63f56c0606221253k7e3d28eejc75bf1be4304c389@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:16512 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932319AbWFWFug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 01:50:36 -0400
To: Robert Iakobashvili <coroberti@gmail.com>
Content-Disposition: inline
In-Reply-To: <7e63f56c0606221253k7e3d28eejc75bf1be4304c389@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 22, 2006 at 09:53:38PM +0200, Robert Iakobashvili (coroberti@gmail.com) wrote:
> Evgeniy,
> 
> On 6/22/06, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> 
> >Kevent subsystem incorporates several AIO/kqueue design notes and ideas.
> >Kevent can be used both for edge and level notifications. It supports
> >socket notifications, network AIO (aio_send(), aio_recv() and
> >aio_sendfile()), inode notifications (create/remove),
> >generic poll()/select() notifications and timer notifications.
> 
> Great job!
> Smooth integration with userland asynch POSIX frameworks
> (e.g. ACE POSIX_Proactor) may require syscalls (or their emulation)
> with POSIX interface:
> 
> * POSIX_API
> * aio_read
> * aio_write
> * aio_suspend
> * aio_error
> * aio_return
> * aio_cancel
> 
> where aio_suspend is very important.

I've designed network AIO differently as how posix declared it's
functions. POSIX AIO is like rocket science - while one tries to
implement them all there is no time to do the real work.
Although all of them including suspend can be emulated on top of
existing calls to kevent.

> -- 
> Sincerely,
> ------------------------------------------------------------------
> Robert Iakobashvili, coroberti at gmail dot com
> Navigare necesse est, vivere non est necesse.
> ------------------------------------------------------------------

-- 
	Evgeniy Polyakov
