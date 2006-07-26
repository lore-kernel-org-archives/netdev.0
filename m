From: Avi Kivity <avi@argo.co.il>
Subject: Re: [3/4] kevent: AIO, aio_sendfile() implementation.
Date: Wed, 26 Jul 2006 17:14:34 +0300
Message-ID: <44C778CA.1010404@argo.co.il>
References: <20060726.031247.98341392.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, johnpol@2ka.mipt.ru,
	linux-kernel@vger.kernel.org, drepper@redhat.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.argo.co.il ([194.90.79.130]:32531 "EHLO
	argo2k.argo.co.il") by vger.kernel.org with ESMTP id S1750728AbWGZOOi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 10:14:38 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060726.031247.98341392.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
>
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
Surely, there needs to be a unified polling interface to support single 
threaded designs.

-- 
error compiling committee.c: too many arguments to function

