From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCHv4 net-next 0/3] Improvements for TCP PMTU
Date: Tue, 3 Mar 2015 11:43:12 -0500
Message-ID: <CABrhC0kXWSq3hrfo=dtnmaor0ciDB2wDPaFQ_Vk40sZe4iCfdw@mail.gmail.com>
References: <1425374361-21047-1-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Fan Du <fengyuleidian0615@gmail.com>
To: Fan Du <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:34001 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756354AbbCCQnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 11:43:14 -0500
Received: by lbiv13 with SMTP id v13so19749156lbi.1
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 08:43:12 -0800 (PST)
In-Reply-To: <1425374361-21047-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 3, 2015 at 4:19 AM, Fan Du <fan.du@intel.com> wrote:
> Fan Du (3):
>   ipv4: Raise tcp PMTU probe mss base size
>   ipv4: Use binary search to choose tcp PMTU probe_size
>   ipv4: Create probe timer for tcp PMTU as per RFC4821
>
>  include/net/inet_connection_sock.h |    2 +
>  include/net/netns/ipv4.h           |    2 +
>  include/net/tcp.h                  |    8 +++++-
>  net/ipv4/sysctl_net_ipv4.c         |   14 +++++++++++
>  net/ipv4/tcp_ipv4.c                |    2 +
>  net/ipv4/tcp_output.c              |   46 ++++++++++++++++++++++++++++++++---
>  net/ipv4/tcp_timer.c               |    1 +
>  7 files changed, 70 insertions(+), 5 deletions(-)
>

This changeset adds a couple new sysctls.  They probably deserve
descriptions in ip-sysctl.txt.

Thanks,
  -John
