From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] ipv6: tcp: clean up tcp_v6_early_demux() icsk variable
Date: Tue, 23 Oct 2012 08:56:54 -0400
Message-ID: <CADVnQynH8PTA_6s3dbFN-udyJeuiDGwv1AFm0tobz9FhF7hwrg@mail.gmail.com>
References: <1350978108.8609.1542.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:58183 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932337Ab2JWM4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 08:56:55 -0400
Received: by mail-qc0-f174.google.com with SMTP id o22so2132112qcr.19
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 05:56:55 -0700 (PDT)
In-Reply-To: <1350978108.8609.1542.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 23, 2012 at 3:41 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Neal Cardwell <ncardwell@google.com>
>
> Remove an icsk variable, which by convention should refer to an
> inet_connection_sock rather than an inet_sock. In the process, make
> the tcp_v6_early_demux() code and formatting a bit more like
> tcp_v4_early_demux(), to ease comparisons and maintenance.
>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv6/tcp_ipv6.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)

Thanks, Eric!

neal
