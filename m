From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: reset timer after any SYNACK retransmit
Date: Mon, 29 Apr 2013 14:57:27 -0400
Message-ID: <CADVnQyn2dWfFwrsFSqBEiB=9m3MsKQR58dEsRpPvAM4rqpviQQ@mail.gmail.com>
References: <1367261091-28052-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, hagen@jauu.net,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f170.google.com ([209.85.215.170]:51068 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758893Ab3D2S53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 14:57:29 -0400
Received: by mail-ea0-f170.google.com with SMTP id z7so2695918eaf.15
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 11:57:28 -0700 (PDT)
In-Reply-To: <1367261091-28052-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 29, 2013 at 2:44 PM, Yuchung Cheng <ycheng@google.com> wrote:
> Linux immediately returns SYNACK on (spurious) SYN retransmits, but
> keeps the SYNACK timer running independently. Thus the timer may
> fire right after the SYNACK retransmit and causes a SYN-SYNACK
> cross-fire burst.
>
> Adopt the fast retransmit/recovery idea in established state by
> re-arming the SYNACK timer after the fast (SYNACK) retransmit. The
> timer may fire late up to 500ms due to the current SYNACK timer wheel,
> but it's OK to be conservative when network is congested. Eric's new
> listener design should address this issue.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
