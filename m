From: Andreas Petlund <apetlund@simula.no>
Subject: Re: [net-next PATCH v3 2/3] net: TCP thin linear timeouts
Date: Sat, 13 Feb 2010 16:50:00 +0100
Message-ID: <4B76CA28.5060709@simula.no>
References: <4B73F30D.6040205@simula.no> <4B753931.30405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?UTF-8?B?SWxwbyBK?= =?UTF-8?B?w6RydmluZW4=?=
	<ilpo.jarvinen@helsinki.fi>, Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>, damian@tvk.rwth-aachen.de
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.2750.no ([62.101.244.198]:59379 "EHLO mail.2750.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757226Ab0BMP6L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Feb 2010 10:58:11 -0500
In-Reply-To: <4B753931.30405@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12. feb. 2010 12:19, William Allen Simpson wrote:
> Last year, I'm pretty sure I was on record as thinking this is only a
> marginally good idea, that would be better at the application layer.
> 
> Also that naming was a bit dicey.  Now the names are more descriptive,
> but the "force" is a bit overkill.
> 
> How about?
>   NET_TCP_FORCE_THIN_LINEAR_TIMEOUTS    -> NET_TCP_THIN_LINEAR_TIMEOUTS
>   TCP_THIN_LT                           -> TCP_THIN_LINEAR_TIMEOUTS
>   TCP_THIN_LT_RETRIES                   -> TCP_THIN_LINEAR_RETRIES
>   tcp_force_thin_linear_timeouts        -> tcp_thin_linear_timeouts
>   sysctl_tcp_force_thin_linear_timeouts -> sysctl_tcp_thin_linear_timeouts
>   tp->thin_lt                           -> tp->thin_lto
> 
> The latter mostly traditional "to" for "timeout", as used most everywhere.
> 

I agree that the _force_-part should be taken out for both patches, and 
renaming the lt to lto also makes sense. I'll fix it in the next iteration.

> Just for efficiency, I'd reorder this
>   +    if (sk->sk_state == TCP_ESTABLISHED &&
>   +        (tp->thin_lt || sysctl_tcp_force_thin_linear_timeouts) &&
>   +        tcp_stream_is_thin(sk) &&
>   +        icsk->icsk_retransmits <= TCP_THIN_LT_RETRIES) {

Thank you for this suggestion. I'll reorder in the next iteration.

Best regards,
Andreas
