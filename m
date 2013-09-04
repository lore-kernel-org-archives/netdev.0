From: Jean Sacren <sakiwit@gmail.com>
Subject: Re: [PATCH net] net: ipv6: tcp: fix potential use after free in
 tcp_v6_do_rcv
Date: Tue, 3 Sep 2013 18:51:57 -0600
Message-ID: <20130904005157.GG8262@mail.gmail.com>
References: <1378229352-9779-1-git-send-email-dborkman@redhat.com>
 <1378230513.7360.37.camel@edumazet-glaptop>
 <20130903194620.GE8262@mail.gmail.com>
 <1378240517.7360.41.camel@edumazet-glaptop>
 <20130903215915.GF8262@mail.gmail.com>
 <1378247352.7360.50.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	Jiri Benc <jbenc@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:34011 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761445Ab3IDAyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 20:54:25 -0400
Received: by mail-pb0-f41.google.com with SMTP id rp2so6764236pbb.28
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 17:54:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1378247352.7360.50.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 03 Sep 2013 15:29:12 -0700
>
> On Tue, 2013-09-03 at 15:59 -0600, Jean Sacren wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Tue, 03 Sep 2013 13:35:17 -0700
> > >
> > > How did you get your conclusion ?
> > 
> > If one changes one line of code, doesn't one own that line?
> > 
> 
> 'Owning' like he is the guy who can sell it ? OK I understand now
> so many people send 'cleanups' ;)

'Owning' like he is the guy who is responsible for the change. Whether
you understand it or not, that's your own business.

The idea was by taking one example to determine who is really to blame
for: Is the one passing on the bug responsible? Thanks to Daniel
Borkmann for the answer.

-- 
Jean Sacren
