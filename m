From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [NOT VERY SAFE]     [TCP]: Set initial_ssthresh default to zero
 in Cubic and BIC.
Date: Mon, 15 Oct 2007 08:55:41 -0700
Message-ID: <20071015085541.48ec63ae@freepuppy.rosehill>
References: <20071006132601.f944f461.komurojun@nifty.com>
	<20071014073658.d4352b8c.komurojun@nifty.com>
	<20071014100245.914b784a.komurojun@nifty.com>
	<20071014132851.8d6a9de3.komurojun@nifty.com>
	<20071014135356.19754635.komurojun-mbn@nifty.com>
	<20071015215949.50399c00.komurojun-mbn@nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux.foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Komuro <komurojun-mbn@nifty.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51221 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752714AbXJOPzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 11:55:54 -0400
In-Reply-To: <20071015215949.50399c00.komurojun-mbn@nifty.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Oct 2007 21:59:49 +0900
Komuro <komurojun-mbn@nifty.com> wrote:

> Dear shemminger
> 
> >In which case it is zero because that is the default value.
> 
> The default value of snd_ssthresh is 0x7fffffff, isn't it?
> 
> [linux/net/ipv4/tcp_ipv4.c]
> static int tcp_v4_init_sock(struct sock *sk)
> ...
>         tp->snd_ssthresh = 0x7fffffff;  /* Infinity */
> ...
> 
> Best Regards
> Komuro
> 
> 

Yes that value means that TCP stays in slow start until the first loss.
This makes TCP behave as expected in the RFC's.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
