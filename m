From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: [PATCH net-next 1/3] ipv4: Raise tcp PMTU probe mss base size
Date: Fri, 13 Feb 2015 17:49:37 +0800
Message-ID: <54DDC8B1.1050307@windriver.com>
References: <1423815405-32644-1-git-send-email-fan.du@intel.com> <1423815405-32644-2-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <fengyuleidian0615@gmail.com>
To: Fan Du <fan.du@intel.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:38644 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751655AbbBMJtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 04:49:32 -0500
In-Reply-To: <1423815405-32644-2-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

backward compatible? :-D

Zhu Yanjun
On 02/13/2015 04:16 PM, Fan Du wrote:
> Quotes from RFC4821 7.2.  Selecting Initial Values
>
>     It is RECOMMENDED that search_low be initially set to an MTU size
>     that is likely to work over a very wide range of environments.  Given
>     today's technologies, a value of 1024 bytes is probably safe enough.
>     The initial value for search_low SHOULD be configurable.
>
> Moreover, set a small value will introduce extra time for the search
> to converge. So set the initial probe base mss size to 1024 Bytes.
>
> Signed-off-by: Fan Du <fan.du@intel.com>
> ---
>   include/net/tcp.h |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 8d6b983..7b57e5b 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -65,7 +65,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
>   #define TCP_MIN_MSS		88U
>   
>   /* The least MTU to use for probing */
> -#define TCP_BASE_MSS		512
> +#define TCP_BASE_MSS		1024
>   
>   /* After receiving this amount of duplicate ACKs fast retransmit starts. */
>   #define TCP_FASTRETRANS_THRESH 3
