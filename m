From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH V2 net] net: fix tcp reset packet flowlabel for ipv6
Date: Tue, 25 Jul 2017 14:32:15 -0700
Message-ID: <20170725213215.xfccqe4igfw3mui5@kernel.org>
References: <25a0abdf61ab4698773d417af9e49fcd6e6559a4.1500393028.git.shli@fb.com>
 <20170724.133455.562898067272108474.davem@davemloft.net>
 <CAM_iQpUGff36UigL39zoh7H=nuzh6EvB6bh4G+jSKsE96uw+aA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        kernel-team <Kernel-team@fb.com>, Shaohua Li <shli@fb.com>,
        Eric Dumazet <eric.dumazet@gmail.com>, flo@fourcot.fr
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:48240 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750880AbdGYVcR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Jul 2017 17:32:17 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpUGff36UigL39zoh7H=nuzh6EvB6bh4G+jSKsE96uw+aA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 24, 2017 at 04:12:53PM -0700, Cong Wang wrote:
> On Mon, Jul 24, 2017 at 1:34 PM, David Miller <davem@davemloft.net> wrote:
> > From: Shaohua Li <shli@kernel.org>
> > Date: Tue, 18 Jul 2017 12:03:37 -0700
> >
> >> +     /* Since this is being sent on the wire obfuscate hash a bit
> >> +      * to minimize possbility that any useful information to an
> >> +      * attacker is leaked. Only lower 20 bits are relevant.
> >> +      */
> >> +     rol32(hash, 16);
> >
> > This doesn't help anything at all.
> 
> I believe the above code is copy-n-pasted from ip6_make_flowlabel()
> (with few adjustments). Don't know why we can't refactor that function
> for reuse.

There are just several lines of code, I really don't want to add adhoc if-else
for fast path.

Thanks,
Shaohua
