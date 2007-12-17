From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Mon, 17 Dec 2007 08:44:11 +0100
Message-ID: <20071217074411.GB1654@ff.dom.local>
References: <20071214083037.GA15602@gondor.apana.org.au> <20071214.111514.03773174.davem@davemloft.net> <20071214151136.ae0f969b.akpm@linux-foundation.org> <20071215041827.GC25324@gondor.apana.org.au> <20071214214418.0ecd5e67.akpm@linux-foundation.org> <20071215061021.GA26247@gondor.apana.org.au> <20071215024810.20b8a5ae.akpm@linux-foundation.org> <47656931.1040309@gmail.com> <20071217012632.GA8475@gondor.apana.org.au> <20071217072601.GA1654@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.185]:29675 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754841AbXLQHi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 02:38:58 -0500
Received: by fk-out-0910.google.com with SMTP id z23so1315482fkz.5
        for <netdev@vger.kernel.org>; Sun, 16 Dec 2007 23:38:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20071217072601.GA1654@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 17, 2007 at 08:26:01AM +0100, Jarek Poplawski wrote:
> On Mon, Dec 17, 2007 at 09:26:32AM +0800, Herbert Xu wrote:
...
> > I retract what I've said in this thread and continue to oppose
> > this change without a might_sleep.
...
> So, I think using might_sleep() explicitly would be much more
> readable or, otherwise, Patrick's proposal with adding
> ASSERT_RTNL_ATOMIC would implicitly signal the real meaning of the
> other one.

OOPS! I've looped again! Of course, ASSERT_RTNL with might_sleep()
would be explicit enough by itself (if we don't believe atomicity
is debugged enough). So, this atomic version could be usable for
other reasons.
 
Jarek P.
