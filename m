From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Wed, 22 Nov 2006 15:15:16 +0300
Message-ID: <20061122121516.GA7229@2ka.mipt.ru>
References: <45564EA5.6020607@redhat.com> <20061113105458.GA8182@2ka.mipt.ru> <4560F07B.10608@redhat.com> <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru> <4563FD53.7030307@redhat.com> <20061122120933.GA32681@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Alexander Viro <aviro@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42908 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1754256AbWKVMQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Nov 2006 07:16:47 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <20061122120933.GA32681@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 22, 2006 at 03:09:34PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> Ok, to solve the problem in the way which should be good for both I
> decided to implement additional syscall which will allow to mark any
> event as ready and thus wake up appropriate threads. If userspace will
> request zero events to be marked as ready, syscall will just
> interrupt/wakeup one of the listeners parked in syscall.

Btw, what about putting aditional multiplexer into add/remove/modify
switch? There will be logical 'ready' addon?

-- 
	Evgeniy Polyakov
