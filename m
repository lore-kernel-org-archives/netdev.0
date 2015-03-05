From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: align tcp_xmit_size_goal() on tcp_tso_autosize()
Date: Thu, 5 Mar 2015 11:13:31 -0500
Message-ID: <CADVnQykSd6==wJv4NpcfazqDSyxF4kRXA5u0NDUJO4hv9a-4jA@mail.gmail.com>
References: <1425571386.5130.247.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:39870 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757661AbbCEQNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 11:13:32 -0500
Received: by qgdq107 with SMTP id q107so5929569qgd.6
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 08:13:31 -0800 (PST)
In-Reply-To: <1425571386.5130.247.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 5, 2015 at 11:03 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> With some mss values, it is possible tcp_xmit_size_goal() puts
> one segment more in TSO packet than tcp_tso_autosize().
>
> We send then one TSO packet followed by one single MSS.
>
> It is not a serious bug, but we can do slightly better, especially
> for drivers using netif_set_gso_max_size() to lower gso_max_size.
>
> Using same formula avoids these corner cases and makes
> tcp_xmit_size_goal() a bit faster.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 605ad7f184b6 ("tcp: refine TSO autosizing")

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
