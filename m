From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 1/7] tcp: do not assume TCP code is non
 preemptible
Date: Fri, 29 Apr 2016 07:37:25 -0700
Message-ID: <1461940645.5535.144.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461899449-8096-1-git-send-email-edumazet@google.com>
	 <1461899449-8096-2-git-send-email-edumazet@google.com>
	 <CACSApvYruzhRVLWbHowsPpfnN0f1vhqRywt-2j1vCOFxmmV9+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Soheil Hassas Yeganeh <soheil@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f174.google.com ([209.85.161.174]:35669 "EHLO
	mail-yw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752819AbcD2Oh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 10:37:29 -0400
Received: by mail-yw0-f174.google.com with SMTP id g133so168417678ywb.2
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 07:37:29 -0700 (PDT)
In-Reply-To: <CACSApvYruzhRVLWbHowsPpfnN0f1vhqRywt-2j1vCOFxmmV9+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-29 at 09:18 -0400, Soheil Hassas Yeganeh wrote:
> On Thu, Apr 28, 2016 at 11:10 PM, Eric Dumazet <edumazet@google.com> wrote:

> > +                               NET_ADD_STATS(sock_net(sk),
> > +                                             LINUX_MIB_TCPHYSTARTTRAINCWND,
> > +                                             pp>>sn__cwdd);
> nit: shouldn't this be tp->snd_cwnd?

Interesting... my git tree has the proper thing, but the file on my SSD
after git format-patch got mangled somehow...

Thanks for noticing !
