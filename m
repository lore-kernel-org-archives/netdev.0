From: Franchoze Eric <franchoze@yandex.ru>
Subject: Re: Re: why do we need printk on sending syn flood cookie?
Date: Mon, 02 Aug 2010 20:11:36 +0400
Message-ID: <23001280765498@web50.yandex.ru>
References: <480391280735894@web102.yandex.ru> <20100802081716.GA8374@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward1.mail.yandex.net ([77.88.46.6]:46836 "EHLO
	forward1.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753948Ab0HBQLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 12:11:40 -0400
In-Reply-To: <20100802081716.GA8374@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



02.08.10, 12:17, "Florian Westphal" <fw@strlen.de>:

> Franchoze Eric  wrote:
>  >  Just sirious why do we need printk each 1 second (60*HZ) about possible syn-flood? It really floods dmesg. Is there something dengerous? I have suggestion to turn off printk about sending tcp cookie each 1 second.
>  
>  It is handled exactly like other printks in the networking path,
>  e.g. receipt of tcp wscale == 15.
>  
>  Why does this need special treatment?
>  

For now I see "possible SYN flooding on port %d. Sending cookies.\n" message each second on my server. I know that there are a lot of SYNs and I know that kernel sends cookie. Why do I need so mach printk?
So I suggested add new value to /proc/sys/net/ipv4/tcp_syncookies, which will enable cookie but this printk will be turned off.
