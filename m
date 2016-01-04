From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: Implement fast csum_partial for x86_64
Date: Mon, 04 Jan 2016 14:36:28 -0800
Message-ID: <1451946988.8255.78.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1451863347-1832521-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:32959 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752586AbcADWgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 17:36:31 -0500
Received: by mail-pf0-f175.google.com with SMTP id q63so172826783pfb.0
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 14:36:31 -0800 (PST)
In-Reply-To: <1451863347-1832521-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-01-03 at 15:22 -0800, Tom Herbert wrote:
\...
> +402: /* Length 2, align is 1, 3, or 5 */
> +	movb	(%rdi), %al
> +	movb	1(%rdi), %ah

Looks like a movw (%rdi),%ax


Also you probably should send this patch to x86 maintainers.
