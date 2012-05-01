From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 3/3] RFC tcp: early retransmit: delayed fast retransmit
Date: Tue, 1 May 2012 13:55:11 -0400
Message-ID: <CADVnQym=5RLNS6A2stNtan56na9U+280_qFGtmjos0jcK9nAcg@mail.gmail.com>
References: <1335638781-960-1-git-send-email-ycheng@google.com>
	<1335638781-960-3-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, edumazet@gmail.com, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:57466 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756875Ab2EARzM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 13:55:12 -0400
Received: by yhmm54 with SMTP id m54so42459yhm.19
        for <netdev@vger.kernel.org>; Tue, 01 May 2012 10:55:11 -0700 (PDT)
In-Reply-To: <1335638781-960-3-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 28, 2012 at 2:46 PM, Yuchung Cheng <ycheng@google.com> wrot=
e:
> Implementing the advanced early retransmit (sysctl_tcp_early_retrans=3D=
=3D2).
> Delays the fast retransmit by an interval of RTT/4. We borrow the
> RTO timer to implement the delay. If we receive another ACK or send
> a new packet, the timer is cancelled and restored to original RTO
> value offset by time elapsed. =A0When the delayed-ER timer fires,
> we enter fast recovery and perform fast retransmit.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
> =A0include/linux/tcp.h =A0 | =A0 =A04 +-
> =A0include/net/tcp.h =A0 =A0 | =A0 =A03 ++
> =A0net/ipv4/tcp_input.c =A0| =A0 69 +++++++++++++++++++++++++++++++++=
+++++++++++-----
> =A0net/ipv4/tcp_output.c | =A0 =A05 +--
> =A0net/ipv4/tcp_timer.c =A0| =A0 =A05 +++
> =A05 files changed, 74 insertions(+), 12 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
