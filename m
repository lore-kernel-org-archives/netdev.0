From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [3/4] kevent: AIO, aio_sendfile() implementation.
Date: Wed, 26 Jul 2006 11:15:39 +0100
Message-ID: <20060726101539.GA8711@infradead.org>
References: <1153905495613@2ka.mipt.ru> <11539054952574@2ka.mipt.ru> <20060726100431.GA7518@infradead.org> <20060726.031247.98341392.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@infradead.org, johnpol@2ka.mipt.ru,
	linux-kernel@vger.kernel.org, drepper@redhat.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:5777 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S932098AbWGZKPq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 06:15:46 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060726.031247.98341392.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 26, 2006 at 03:12:47AM -0700, David Miller wrote:
> From: Christoph Hellwig <hch@infradead.org>
> Date: Wed, 26 Jul 2006 11:04:31 +0100
> 
> > And to be honest, I don't think adding all this code is acceptable
> > if it can't replace the existing aio code while keeping the
> > interface.  So while you interface looks pretty sane the
> > implementation needs a lot of work still :)
> 
> Networking and disk AIO have significantly different needs.
> 
> Therefore, I really don't see it as reasonable to expect
> a merge of these two things.  It doesn't make any sense.

I'm not sure about that.  The current aio interface isn't exactly nice
for disk I/O either.  I'm more than happy to have a discussion about
that aspect.

