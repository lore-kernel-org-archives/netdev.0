From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 2/4 net-next] tcp: prefer packet timing to TS-ECR for RTT
Date: Sun, 21 Jul 2013 23:17:44 -0400
Message-ID: <CADVnQyntukzrVuF9XfN-=hxT1c32tLcCHTQWzo2t6+0EzKxb5A@mail.gmail.com>
References: <1374385170-358-1-git-send-email-ycheng@google.com>
	<1374385170-358-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:63378 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754160Ab3GVDRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 23:17:46 -0400
Received: by mail-ee0-f47.google.com with SMTP id e49so3464389eek.20
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 20:17:44 -0700 (PDT)
In-Reply-To: <1374385170-358-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 21, 2013 at 1:39 AM, Yuchung Cheng <ycheng@google.com> wrote:
> Prefer packet timings to TS-ecr for RTT measurements when both
> sources are available. That's because broken middle-boxes and remote
> peer can return packets with corrupted TS ECR fields. Similarly most
> congestion controls that require RTT signals favor timing-based
> sources as well. Also check for bad TS ECR values to avoid RTT
> blow-ups. It has happened on production Web servers.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>
