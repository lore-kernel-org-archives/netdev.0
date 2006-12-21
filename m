From: jamal <hadi@cyberus.ca>
Subject: Re: [take28-resend_1->0 0/8] kevent: Generic event handling
	mechanism.
Date: Thu, 21 Dec 2006 09:40:26 -0500
Message-ID: <1166712026.3749.60.camel@localhost>
References: <3154985aa0591036@2ka.mipt.ru> <11666924573643@2ka.mipt.ru>
	 <20061221103539.GA4099@2ka.mipt.ru> <458A64E5.4050703@garzik.org>
	 <20061221104918.GA16744@2ka.mipt.ru> <1166708885.3749.49.camel@localhost>
	 <20061221140429.GA25214@2ka.mipt.ru> <1166710867.3749.56.camel@localhost>
	 <20061221142337.GA17204@2ka.mipt.ru>  <20061221143621.GA32706@2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.233]:63616 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965160AbWLUOka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Dec 2006 09:40:30 -0500
Received: by nz-out-0506.google.com with SMTP id s1so992163nze
        for <netdev@vger.kernel.org>; Thu, 21 Dec 2006 06:40:29 -0800 (PST)
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061221143621.GA32706@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-21-12 at 17:36 +0300, Evgeniy Polyakov wrote:

> Btw, it uses only read/write/signal on fd events, so it must use
> ->poll() and thus be as fast as epoll. 
> 

It is supposed to "detect" the best mechanism in the kernel and switch
to that.
At the moment for example in my app it defaults to epoll.

> Things like sockets/pipes can only benefit from direct kevent usage 
> instead of ->poll() and wrappers.

You should be able change it to use those schemes when it detects
that the kernel supports them.

cheers,
jamal

