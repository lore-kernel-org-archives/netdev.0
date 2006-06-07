From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] Right prototype of __raw_v4_lookup()
Date: Wed, 7 Jun 2006 15:38:39 +0400
Message-ID: <20060607113839.GA7268@martell.zuzino.mipt.ru>
References: <20060527210932.GB7267@martell.zuzino.mipt.ru> <20060605.210707.39159307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:15389 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751134AbWFGLid (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 07:38:33 -0400
Received: by nf-out-0910.google.com with SMTP id o25so123405nfa
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2006 04:38:31 -0700 (PDT)
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060605.210707.39159307.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 05, 2006 at 09:07:07PM -0700, David Miller wrote:
> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Sun, 28 May 2006 01:09:32 +0400
>
> > All users pass 32-bit values as addresses and internally they're compared with
> > 32-bit entities. So, change "laddr" and "raddr" types to __be32.

> Applied.
>
> Doesn't this mean that, at least eventually, we should change
> the address members of inet_sock to __be32 as well?

I think, yes. Al Viro is sitting on terabytes of endian annotations in
networking code. See net-endian.b* branches at
git://git.kernel.org/pub/scm/linux/kernel/git/viro/bird.git
I don't know if he considers them ready.

