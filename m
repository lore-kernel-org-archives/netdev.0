From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 0/2] netpoll: Trivial updates
Date: Fri, 01 Jul 2011 11:26:56 +0800
Message-ID: <4E0D3E80.5080209@redhat.com>
References: <cover.1309482314.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6455 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754254Ab1GAD1A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2011 23:27:00 -0400
In-Reply-To: <cover.1309482314.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2011=E5=B9=B407=E6=9C=8801=E6=97=A5 09:08, Joe Perches =E5=86=
=99=E9=81=93:
> cc: WANG Cong<amwang@redhat.com>
>
> Joe Perches (2):
>    netpoll: Remove unused EXPORT_SYMBOLs of netpoll_poll and netpoll_=
poll_dev
>    netpoll: Remove trivial wrapper function netpoll_poll
>
>   include/linux/netpoll.h |    2 --
>   net/core/netpoll.c      |   13 +++----------
>   2 files changed, 3 insertions(+), 12 deletions(-)
>

I am fine with patch 1/2, but not 2/2, since it is trivial,
why touch it? With netpoll_poll(), we don't need to explore the
details of struct netpoll, I think it is nice to have it.

BTW, you can kill the export of netpoll_send_skb_on_dev() too.

Thanks.
