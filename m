From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take37 0/10] kevent: Generic event handling mechanism (socket, pipes, files, signals, AIO, timers, posix timers...).
Date: Thu, 22 Feb 2007 18:27:17 +0300
Message-ID: <20070222152717.GA18655@2ka.mipt.ru>
References: <asasdasdzxczc036@2ka.mipt.ru> <11721524921823@2ka.mipt.ru> <20070222151740.GD4113@slug>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>, Ch@pimp.vs19.net
To: Frederik Deweerdt <deweerdt@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42478 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633AbXBVPdT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 10:33:19 -0500
Content-Disposition: inline
In-Reply-To: <20070222151740.GD4113@slug>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 22, 2007 at 03:17:40PM +0000, Frederik Deweerdt (deweerdt@free.fr) wrote:
> On Thu, Feb 22, 2007 at 04:54:52PM +0300, Evgeniy Polyakov wrote:
>  
> > Changes from 'take36' patchset:
> >  * ported to 2.6.21-rc1
> Hi Evgeniy,
> 
> The changes below were needed to be able to compile take37 on 2.6.21-rc1
> with:
> CONFIG_KEVENT=y
> CONFIG_KEVENT_USER_STAT=y
> CONFIG_KEVENT_TIMER=y
> CONFIG_KEVENT_POLL=y
> CONFIG_KEVENT_SOCKET=y
> CONFIG_KEVENT_PIPE=y
> CONFIG_KEVENT_SIGNAL=y
> CONFIG_KEVENT_UNOTIFY=y
> CONFIG_KEVENT_AIO=y
> 
> Regards,
> Frederik

Shame on me - I started to make to many such errors last time.
I've applied a patch, thanks a lot Frederik.

-- 
	Evgeniy Polyakov
