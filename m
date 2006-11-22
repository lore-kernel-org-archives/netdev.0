From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Wed, 22 Nov 2006 07:33:46 -0500
Message-ID: <456443AA.7060106@garzik.org>
References: <11630606361046@2ka.mipt.ru> <45564EA5.6020607@redhat.com> <20061113105458.GA8182@2ka.mipt.ru> <4560F07B.10608@redhat.com> <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <45622228.80803@garzik.org> <456223AC.5080400@redhat.com> <456436CA.7050809@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ulrich Drepper <drepper@redhat.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Alexander Viro <aviro@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:9611 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1755096AbWKVMeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Nov 2006 07:34:12 -0500
To: Michael Tokarev <mjt@tls.msk.ru>
In-Reply-To: <456436CA.7050809@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Tokarev wrote:
> Can't the argument be something like u64 instead of struct timespec,
> regardless of this discussion (relative vs absolute)?


Newer syscalls (ppoll, pselect) take struct timespec, which is a 
reasonable, modern form of the timeout argument...

	Jeff


