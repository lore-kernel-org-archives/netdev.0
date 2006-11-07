From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [take21 0/4] kevent: Generic event handling mechanism.
Date: Tue, 07 Nov 2006 07:32:20 -0500
Message-ID: <45507CD4.5030600@garzik.org>
References: <11619654014077@2ka.mipt.ru> <45506D51.30604@garzik.org> <20061107115111.GA13028@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:25018 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750953AbWKGMcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 07:32:32 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061107115111.GA13028@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Mmap ring buffer implementation was stopped by Andrew Morton and Ulrich
> Drepper, process' memory is used instead. copy_to_user() is slower (and
> some times noticebly), but there are major advantages of such approach.


hmmmm.  I say there are advantages to both.

Perhaps create a "kevent_direct_limit" resource limit for each thread. 
By default, each thread could mmap $n pinned pagecache pages.  Sysadmin 
can tune certain app resource limits to permit more.

I would think that retaining the option to avoid copy_to_user() 
-somehow- in -some- cases would be wise.

	Jeff


