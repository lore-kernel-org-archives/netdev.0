From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v6 net-next 2/2] tcp: switch rtt estimations to usec resolution
Date: Tue, 25 Feb 2014 14:13:24 -0500
Message-ID: <CADVnQymdZyE-Mb4F6QnTcJhHp4R9=GnYK9cTTpohQMFC=aK-Vw@mail.gmail.com>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>
	<alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg>
	<1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>
	<1393181458.2316.56.camel@edumazet-glaptop2.roam.corp.google.com>
	<1393216927.2316.62.camel@edumazet-glaptop2.roam.corp.google.com>
	<1393266251.2316.68.camel@edumazet-glaptop2.roam.corp.google.com>
	<alpine.LFD.2.11.1402242240290.1941@ja.home.ssi.bg>
	<1393280025.2316.76.camel@edumazet-glaptop2.roam.corp.google.com>
	<alpine.LFD.2.11.1402250056250.1941@ja.home.ssi.bg>
	<1393284682.2316.83.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140224155130.4c286cca@samsung-9>
	<1393290667.2316.96.camel@edumazet-glaptop2.roam.corp.google.com>
	<1393292339.2316.98.camel@edumazet-glaptop2.roam.corp.google.com>
	<1393309341.2316.120.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Yuchung Cheng <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>, Larry Brakmo <brakmo@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:47322 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966AbaBYTNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 14:13:25 -0500
Received: by mail-ea0-f182.google.com with SMTP id r15so334688ead.27
        for <netdev@vger.kernel.org>; Tue, 25 Feb 2014 11:13:24 -0800 (PST)
In-Reply-To: <1393309341.2316.120.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 25, 2014 at 1:22 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Upcoming congestion controls for TCP require usec resolution for RTT
> estimations. Millisecond resolution is simply not enough these days.
>
> FQ/pacing in DC environments also require this change for finer control
> and removal of bimodal behavior due to the current hack in
> tcp_update_pacing_rate() for 'small rtt'
>
...
> ---
> v6: Do not use ktime_get() but skb_mstamp, as Stephen Hemminger pointed
>     out some platforms have slow ktime_get()
>
...
>  17 files changed, 174 insertions(+), 169 deletions(-)

> I think it is safe, because we made sure (sack_rtt_us >= 0) is true.

Sounds good. Thanks, Eric!

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
