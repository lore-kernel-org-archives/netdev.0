From: "David M. Lloyd" <dmlloyd@flurg.com>
Subject: Re: [take35 0/10] kevent: Generic event handling mechanism.
Date: Mon, 05 Feb 2007 11:28:05 -0600
Message-ID: <1170696485.22199.1.camel@localhost>
References: <11703247503374@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound4.mail.tds.net ([216.170.230.94]:35482 "EHLO
	outbound4.mail.tds.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965344AbXBFF4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 00:56:19 -0500
In-Reply-To: <11703247503374@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-02-01 at 13:12 +0300, Evgeniy Polyakov wrote:
> Generic event handling mechanism.

The patch applied cleanly to 2.6.20 final, but I got a build error:

  CC      kernel/kevent/kevent.o
  CC      kernel/kevent/kevent_user.o
  CC      kernel/kevent/kevent_timer.o
  CC      kernel/kevent/kevent_poll.o
make[2]: *** No rule to make target `kernel/kevent/epoll.o', needed by `kernel/kevent/built-in.o'.  Stop.
make[1]: *** [kernel/kevent] Error 2
make: *** [kernel] Error 2

- DML

