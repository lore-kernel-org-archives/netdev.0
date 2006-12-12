From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [take26-resend1 0/8] kevent: Generic event handling mechanism.
Date: Tue, 12 Dec 2006 08:39:33 -0500
Message-ID: <457EB115.3020407@garzik.org>
References: <1165848619971@2ka.mipt.ru> <457D764E.9040308@garzik.org> <20061212053902.GC14420@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
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
Received: from srv5.dvmed.net ([207.36.208.214]:55574 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751336AbWLLNjr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Dec 2006 08:39:47 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061212053902.GC14420@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Mon, Dec 11, 2006 at 10:16:30AM -0500, Jeff Garzik (jeff@garzik.org) wrote:
>> Comments:
>>
>> * [oh, everybody will hate me for saying this, but...]  to me, "kevent" 
>> implies an internal kernel subsystem.  I would rather call it "uevent" 
>> or anything else lacking a 'k' prefix.
> 
> It is kernel subsystem indeed, which exports some of its part to
> userspace.
> I previously thought that prefix 'k' can only be confused with KDE.

It is a true statement to say "without the kevent subsystem, userspace 
lacks uevent handling".

And let's be honest, the main consumers of this will be userspace apps, 
and a few in-kernel users pretending to be userspace apps (kernel threads).

	Jeff



