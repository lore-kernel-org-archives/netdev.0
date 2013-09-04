From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] net: ipv6: tcp: fix potential use after free in
 tcp_v6_do_rcv
Date: Wed, 4 Sep 2013 08:26:39 +0200
Message-ID: <20130904082639.5c5e3bb4@griffin>
References: <1378229352-9779-1-git-send-email-dborkman@redhat.com>
	<1378230513.7360.37.camel@edumazet-glaptop>
	<20130903194620.GE8262@mail.gmail.com>
	<1378240517.7360.41.camel@edumazet-glaptop>
	<20130903215915.GF8262@mail.gmail.com>
	<1378247352.7360.50.camel@edumazet-glaptop>
	<20130904005157.GG8262@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44623 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761946Ab3IDG0y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 02:26:54 -0400
In-Reply-To: <20130904005157.GG8262@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 3 Sep 2013 18:51:57 -0600, Jean Sacren wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 03 Sep 2013 15:29:12 -0700
> >
> > On Tue, 2013-09-03 at 15:59 -0600, Jean Sacren wrote:
> > > From: Eric Dumazet <eric.dumazet@gmail.com>
> > > Date: Tue, 03 Sep 2013 13:35:17 -0700
> > > >
> > > > How did you get your conclusion ?
> > > 
> > > If one changes one line of code, doesn't one own that line?
> > > 
> > 
> > 'Owning' like he is the guy who can sell it ? OK I understand now
> > so many people send 'cleanups' ;)
> 
> 'Owning' like he is the guy who is responsible for the change. Whether
> you understand it or not, that's your own business.
> 
> The idea was by taking one example to determine who is really to blame
> for: Is the one passing on the bug responsible? Thanks to Daniel
> Borkmann for the answer.

Eric is correct, the bug was introduced by me.

Sorry for it. Daniel, thanks for fixing it.

Acked-by: Jiri Benc <jbenc@redhat.com>

-- 
Jiri Benc
