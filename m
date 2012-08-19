From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPv4 BUG: held lock freed!
Date: Sun, 19 Aug 2012 17:55:08 +0200
Message-ID: <1345391708.5158.225.camel@edumazet-glaptop>
References: <20120818021918.GA6499@localhost>
	 <1345380682.5158.201.camel@edumazet-glaptop>
	 <CAF1ivSaU_ur9BkKG3eAsNw7d+ND5xgYbPKutemVqNec3X9m4SA@mail.gmail.com>
	 <1345387532.5158.222.camel@edumazet-glaptop>
	 <CAF1ivSZK8Y2XpjUXVpNg=m=bs7bGCYqF0ZQU2u_YpEUrmOrR-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	David Miller <davem@davemloft.net>,
	networking <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Lin Ming <mlin@ss.pku.edu.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:47768 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825Ab2HSPzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2012 11:55:14 -0400
In-Reply-To: <CAF1ivSZK8Y2XpjUXVpNg=m=bs7bGCYqF0ZQU2u_YpEUrmOrR-g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-08-19 at 23:05 +0800, Lin Ming wrote:
> On Sun, Aug 19, 2012 at 10:45 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Sun, 2012-08-19 at 22:15 +0800, Lin Ming wrote:
> >
> >> Will it still has problem if code goes here without sock_hold(sk)?
> >
> > Not sure of what you mean.
> 
> See my comments in the function.
> Is that a potential problem?
> 

No problem.

It always been like that. Thats the whole point having a refcount at the
first place.

The last sock_put(sk) should free the socket.
