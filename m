From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [take21 0/4] kevent: Generic event handling mechanism.
Date: Tue, 07 Nov 2006 07:17:03 -0500
Message-ID: <4550793F.4070102@garzik.org>
References: <11619654014077@2ka.mipt.ru> <45506D51.30604@garzik.org> <20061107115111.GA13028@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:63673 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1754223AbWKGMRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 07:17:08 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061107115111.GA13028@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Well, kevent network and FS AIO are suspended for now (although first

Why?

IMO, getting async event submission right is important.  It should be 
designed in parallel with async event reception.

	Jeff


