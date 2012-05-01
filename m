From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 1/3] RFC tcp: early retransmit: tcp_enter_recovery()
Date: Tue, 1 May 2012 13:54:23 -0400
Message-ID: <CADVnQy=wEjFjnVwFT2MUzQJgm=RwMqk3SCK2uTPv5gRUOS69Ug@mail.gmail.com>
References: <1335638781-960-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, edumazet@gmail.com, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:63306 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754756Ab2EARyY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 13:54:24 -0400
Received: by ghrr11 with SMTP id r11so2189588ghr.19
        for <netdev@vger.kernel.org>; Tue, 01 May 2012 10:54:23 -0700 (PDT)
In-Reply-To: <1335638781-960-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 28, 2012 at 2:46 PM, Yuchung Cheng <ycheng@google.com> wrot=
e:
> This a prepartion patch that refactors the code to enter recovery
> into a new function tcp_enter_recovery(). It's needed to implement
> the delayed fast retransmit in ER.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
> ChangeLog in v2:
> =A0Fix sysctl_tcp_early_retrans default to 2
> =A0Re-arrange the patch parts so they are individually compilable and=
 functional.
>
> =A0net/ipv4/tcp_input.c | =A0 61 +++++++++++++++++++++++++++---------=
-------------
> =A01 files changed, 34 insertions(+), 27 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

BTW, I think this is a nice clean-up, independent of early retransmit.

neal
