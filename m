From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: [PATCH] xfrm: avoid spinlock in get_acqseq()
Date: Fri, 29 Jan 2010 12:01:07 -0500
Message-ID: <20100129170107.GI20701@kvack.org>
References: <1264773952.3184.22.camel@edumazet-laptop> <20100129151149.GD20701@kvack.org> <1264780819.3184.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:55126 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752407Ab0A2RBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 12:01:09 -0500
Content-Disposition: inline
In-Reply-To: <1264780819.3184.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2010 at 05:00:19PM +0100, Eric Dumazet wrote:
> Not sure its needed now that atomic_t is an integral 32bits type for all
> arches, or a cleanup patch is wanted :)
> 
> Thanks !

Ah, yes, it looks like things have changed in this area a bit over time.  
I'll do up a cleanup patch for this.

		-ben
