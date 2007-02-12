From: Alan <alan@lxorguk.ukuu.org.uk>
Subject: Re: [take36 10/10] kevent: Kevent based generic AIO.
Date: Mon, 12 Feb 2007 13:12:57 +0000
Message-ID: <20070212131257.565f8066@localhost.localdomain>
References: <11712796493850@2ka.mipt.ru>
	<1171279650540@2ka.mipt.ru>
	<p733b5bh6bp.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:34164 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S964880AbXBLNDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 08:03:32 -0500
In-Reply-To: <p733b5bh6bp.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I'm sure others would want them then for their favourite system call combo
> too. If they were really useful it might make more sense to have a batch() 
> system call that works for arbitary calls, but I'm not convinced yet
> it's even needed. It would be certainly ugly.

batch() would possibly make a lot of sense in terms of the fibril/thread
based removal for the need for all the AIO stuff, just to provide a
natural way to group and order sequences of synchronous operations into
asynchronous groups.

I am extremely sceptical about the need for aio_sendfile_path since with
sendfile/sendpath hacking around there didn't seem to be much gain.

I'm even more sceptical of the header buffer stuff as while other OS's do
that as a hack to make TCP packetising work we simply fixed the root
problem with TCP_CORK

Alan
