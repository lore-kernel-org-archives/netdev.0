From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: ipv6: tcp: fix potential use after free in
 tcp_v6_do_rcv
Date: Tue, 03 Sep 2013 15:29:12 -0700
Message-ID: <1378247352.7360.50.camel@edumazet-glaptop>
References: <1378229352-9779-1-git-send-email-dborkman@redhat.com>
	 <1378230513.7360.37.camel@edumazet-glaptop>
	 <20130903194620.GE8262@mail.gmail.com>
	 <1378240517.7360.41.camel@edumazet-glaptop>
	 <20130903215915.GF8262@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	Jiri Benc <jbenc@redhat.com>
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:60615 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754129Ab3ICW3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 18:29:14 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so6627440pdi.41
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 15:29:13 -0700 (PDT)
In-Reply-To: <20130903215915.GF8262@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-03 at 15:59 -0600, Jean Sacren wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 03 Sep 2013 13:35:17 -0700
> >
> > How did you get your conclusion ?
> 
> If one changes one line of code, doesn't one own that line?
> 

'Owning' like he is the guy who can sell it ? OK I understand now
so many people send 'cleanups' ;)

Someone adding a space is not responsible for the real bug.

You'll have to be very careful to do proper attributions.

This is _critical_ for proper stable submissions.

In this case we want the fix to reach linux-3.4 and further versions.

The commit you pointed out was for linux-3.9, and added no bug.
