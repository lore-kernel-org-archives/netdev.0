From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v4 3/3] tcp: early retransmit: delayed fast retransmit
Date: Wed, 2 May 2012 20:15:19 -0400
Message-ID: <CADVnQy=cYPN20JjG47VjsfH12dq7T7-LC0z0XUWhBCo8SCo2cg@mail.gmail.com>
References: <1336001404-21879-1-git-send-email-ycheng@google.com>
	<1336001404-21879-3-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:44918 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893Ab2ECAPU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 20:15:20 -0400
Received: by yenm10 with SMTP id m10so806758yen.19
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 17:15:20 -0700 (PDT)
In-Reply-To: <1336001404-21879-3-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 2, 2012 at 7:30 PM, Yuchung Cheng <ycheng@google.com> wrote=
:
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
> ChangeLog in v2:
> =A0- Set sysctl_tcp_early_retrans default to 2
> ChangeLog in v3:
> =A0- use separate u8 for early retrans stats in tcp_sock
> =A0- disable ER if detects any reordering
> ChangeLog in v4:
> =A0- move disabling ER code on reordering into part2

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
