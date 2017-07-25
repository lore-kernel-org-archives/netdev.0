From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH V2 net] net: fix tcp reset packet flowlabel for ipv6
Date: Tue, 25 Jul 2017 14:35:06 -0700
Message-ID: <20170725213506.jfnbinozo6mzyzpc@kernel.org>
References: <25a0abdf61ab4698773d417af9e49fcd6e6559a4.1500393028.git.shli@fb.com>
 <20170724.133455.562898067272108474.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Kernel-team@fb.com, shli@fb.com,
        eric.dumazet@gmail.com, flo@fourcot.fr
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:48702 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751202AbdGYVfI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Jul 2017 17:35:08 -0400
Content-Disposition: inline
In-Reply-To: <20170724.133455.562898067272108474.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 24, 2017 at 01:34:55PM -0700, David Miller wrote:
> From: Shaohua Li <shli@kernel.org>
> Date: Tue, 18 Jul 2017 12:03:37 -0700
> 
> > +	/* Since this is being sent on the wire obfuscate hash a bit
> > +	 * to minimize possbility that any useful information to an
> > +	 * attacker is leaked. Only lower 20 bits are relevant.
> > +	 */
> > +	rol32(hash, 16);
> 
> This doesn't help anything at all.
> 
> I don't like things that try to give a sense of security (however
> little) but actually don't give any at all.
> 
> I'd rather, therefore, that you remove this altogether.

ok, so you suggest removing the rol32() for ip6_make_flowlabel too, right? just
want to make sure.

Thanks,
Shaohua
