From: Martin Lucina <mato@kotelna.sk>
Subject: Re: [PATCH] Document the kernel_recvmsg() function
Date: Fri, 10 Dec 2010 18:35:56 +0100
Message-ID: <20101210173556.GA6420@dezo.moloch.sk>
References: <20101210100404.GA28580@dezo.moloch.sk> <20101210092836.0801f126.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Martin Sustrik <sustrik@250bpm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chrocht.moloch.sk ([62.176.169.44]:59829 "EHLO mail.moloch.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750789Ab0LJRf7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 12:35:59 -0500
Content-Disposition: inline
In-Reply-To: <20101210092836.0801f126.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rdunlap@xenotime.net said:
> On Fri, 10 Dec 2010 11:04:05 +0100 Martin Lucina wrote:
> 
> > [Updated and sent to the netdev mailing list, Eric thx for the pointer]
> > 
> > Hi,
> > 
> > so, today we spent all day figuring out how the kernel_sendmsg() function
> 
>                                                   ^^^^^^^^^^^^^^
> 
> Maybe you could document that one also??  Thanks.

Sorry, that was a typo. But yes, we'll get to kernel_sendmsg(), as soon as
we can actually test that properly...

In any case, kernel_recvmsg() appears to be the more evil of the two, since
it was not obvious at all that it modifies the pointers passed in to kvec.

-mato
