From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Thu, 21 May 2009 20:10:00 +0400
Message-ID: <20090521161000.GA6638@ioremap.net>
References: <20090520230652.GB5956@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from broadrack.ru ([195.178.208.66]:47991 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754597AbZEUQK3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 12:10:29 -0400
Content-Disposition: inline
In-Reply-To: <20090520230652.GB5956@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnaldo.

On Wed, May 20, 2009 at 08:06:52PM -0300, Arnaldo Carvalho de Melo (acme@redhat.com) wrote:
> Meaning receive multiple messages, reducing the number of syscalls and
> net stack entry/exit operations.
> 
> Next patches will introduce mechanisms where protocols that want to
> optimize this operation will provide an unlocked_recvmsg operation.
 
What's the difference from the single msg with multiple iovecs?

Can we implement receiving from multiple sockets using this or similar interface?

-- 
	Evgeniy Polyakov
