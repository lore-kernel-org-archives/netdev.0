From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 4/4 net-next] tcp: use RTT from SACK for RTO
Date: Sun, 21 Jul 2013 23:40:07 -0400
Message-ID: <CADVnQykoQiGEvHsmtfjhVVGZPDNhHz6BqsNE+s-0Bjf+Q+Gx5A@mail.gmail.com>
References: <1374385170-358-1-git-send-email-ycheng@google.com>
	<1374385170-358-4-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:53605 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756095Ab3GVDkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 23:40:08 -0400
Received: by mail-ee0-f51.google.com with SMTP id e52so3568278eek.10
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 20:40:07 -0700 (PDT)
In-Reply-To: <1374385170-358-4-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 21, 2013 at 1:39 AM, Yuchung Cheng <ycheng@google.com> wrote:
> If RTT is not available because Karn's check has failed or no
> new packet is acked, use the RTT measured from SACK to estimate
> the RTO. The sender can continue to estimate the RTO during loss
> recovery or reordering event upon receiving non-partial ACKs.
>
> This also changes when the RTO is re-armed. Previously it is
> only re-armed when some data is cummulatively acknowledged (i.e.,
> SND.UNA advances), but now it is re-armed whenever RTT estimator
> is updated. This feature is particularly useful to reduce spurious
> timeout for buffer bloat including cellular carriers [1], and
> RTT estimation on reordering events.
>
> [1] "An In-depth Study of LTE: Effect of Network Protocol and
>  Application Behavior on Performance", In Proc. of SIGCOMM 2013
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>
