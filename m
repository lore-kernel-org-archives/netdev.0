From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: [PATCH] xfrm: avoid spinlock in get_acqseq()
Date: Fri, 29 Jan 2010 10:11:49 -0500
Message-ID: <20100129151149.GD20701@kvack.org>
References: <1264773952.3184.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:57982 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755319Ab0A2Pjn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 10:39:43 -0500
Content-Disposition: inline
In-Reply-To: <1264773952.3184.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Fri, Jan 29, 2010 at 03:05:52PM +0100, Eric Dumazet wrote:
> Use atomic_inc_return() in get_acqseq() to avoid taking a spinlock
> +	static atomic_t acqseq;

I think that needs to be:
	static atomic_t acqseq = ATOMIC_INIT(0);

Cheers,

	-ben
