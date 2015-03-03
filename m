From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCHv4 net-next 1/3] ipv4: Raise tcp PMTU probe mss base size
Date: Tue, 3 Mar 2015 11:52:39 -0500
Message-ID: <CABrhC0nMEJuPA44OxxQrwPWvLOWfqGpJVS3-xExjY4LD2mx8aA@mail.gmail.com>
References: <1425374361-21047-1-git-send-email-fan.du@intel.com>
	<1425374361-21047-2-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Fan Du <fengyuleidian0615@gmail.com>
To: Fan Du <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:44943 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756618AbbCCQwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 11:52:41 -0500
Received: by lams18 with SMTP id s18so38701279lam.11
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 08:52:39 -0800 (PST)
In-Reply-To: <1425374361-21047-2-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 3, 2015 at 4:19 AM, Fan Du <fan.du@intel.com> wrote:
> Quotes from RFC4821 7.2.  Selecting Initial Values
>
>    It is RECOMMENDED that search_low be initially set to an MTU size
>    that is likely to work over a very wide range of environments.  Given
>    today's technologies, a value of 1024 bytes is probably safe enough.
>    The initial value for search_low SHOULD be configurable.
>
> Moreover, set a small value will introduce extra time for the search
> to converge. So set the initial probe base mss size to 1024 Bytes.
>
> Signed-off-by: Fan Du <fan.du@intel.com>
> ---
>  include/net/tcp.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 8d6b983..7b57e5b 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -65,7 +65,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
>  #define TCP_MIN_MSS            88U
>
>  /* The least MTU to use for probing */
> -#define TCP_BASE_MSS           512
> +#define TCP_BASE_MSS           1024
>
>  /* After receiving this amount of duplicate ACKs fast retransmit starts. */
>  #define TCP_FASTRETRANS_THRESH 3
> --
> 1.7.1
>

Acked-by: John Heffner <johnwheffner@gmail.com>
