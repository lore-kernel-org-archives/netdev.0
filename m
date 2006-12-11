From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [take26-resend1 0/8] kevent: Generic event handling mechanism.
Date: Mon, 11 Dec 2006 10:16:30 -0500
Message-ID: <457D764E.9040308@garzik.org>
References: <1165848619971@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46760 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936362AbWLKPQw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 10:16:52 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <1165848619971@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Comments:

* [oh, everybody will hate me for saying this, but...]  to me, "kevent" 
implies an internal kernel subsystem.  I would rather call it "uevent" 
or anything else lacking a 'k' prefix.

* I like the absolute timespec (and use of timespec itself)

* more on naming:  I think kevent_open would be more natural than 
kevent_init, since it opens a file descriptor.

* why is KEVENT_MAX not equal to KEVENT_POSIX_TIMER?  (perhaps answer 
this question in a comment, if it is not a mistake)

* Kill all the CONFIG_KEVENT_xxx sub-options, or hide them under 
CONFIG_EMBEDDED.  Application developers should NOT be left wondering 
whether or support for KEVENT_INODE was compiled into the kernel.

