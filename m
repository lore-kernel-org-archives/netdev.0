From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net v2] ipv6: fix rtnl locking in setsockopt for anycast
 and multicast
Date: Fri, 5 Sep 2014 12:34:38 -0700
Message-ID: <CAHA+R7MbsZhxB8uo3xvVsS6JWjRV4p2BcgCBVWtVaJ6Tr4ONYA@mail.gmail.com>
References: <CAHA+R7M1qd5g1ta=YFqefgXDf1EfF2_VsJGUvH6Dd+ttnHc_VQ@mail.gmail.com>
	<1409944376.5306.9.camel@localhost>
	<CAHA+R7NSu=wjGsmLapjM4Mbk_oeZ07P+yN0b982otvjoW2jodA@mail.gmail.com>
	<20140905.122539.670916286627732128.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Tommi Rantala <tt.rantala@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	trinity@vger.kernel.org, Dave Jones <davej@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:53592 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbaIETek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 15:34:40 -0400
Received: by mail-la0-f52.google.com with SMTP id b8so3434065lan.11
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 12:34:39 -0700 (PDT)
In-Reply-To: <20140905.122539.670916286627732128.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 5, 2014 at 12:25 PM, David Miller <davem@davemloft.net> wrote:
>
> I thought the retention of RCU locking was reasonable, and that your
> feedback was something I disagreed with.
>
> This is different from ignoring your feedback.

The point is we don't need to backport the patch that far, as I already
mentioned, up to  commit c15b1ccadb323ea
("ipv6: move DAD and addrconf_verify processing to workqueue"),
simply because no one reports any bug.

So we don't have to adjust the patch just for stable in this case.
