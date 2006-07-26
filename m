From: David Miller <davem@davemloft.net>
Subject: Re: [3/4] kevent: AIO, aio_sendfile() implementation.
Date: Wed, 26 Jul 2006 03:12:47 -0700 (PDT)
Message-ID: <20060726.031247.98341392.davem@davemloft.net>
References: <1153905495613@2ka.mipt.ru>
	<11539054952574@2ka.mipt.ru>
	<20060726100431.GA7518@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, linux-kernel@vger.kernel.org,
	drepper@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:8346
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751334AbWGZKMo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 06:12:44 -0400
To: hch@infradead.org
In-Reply-To: <20060726100431.GA7518@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 26 Jul 2006 11:04:31 +0100

> And to be honest, I don't think adding all this code is acceptable
> if it can't replace the existing aio code while keeping the
> interface.  So while you interface looks pretty sane the
> implementation needs a lot of work still :)

Networking and disk AIO have significantly different needs.

Therefore, I really don't see it as reasonable to expect
a merge of these two things.  It doesn't make any sense.

I do agree that this stuff needs to be cleaned up, all the get_block
etc. hacks have to be pulled out and abstracted properly.  That part
of the kevent changes are indeed still crap :)
