From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net ipv4 ipconfig: use preferred log methods
Date: Sun, 27 Sep 2015 22:37:15 -0700
Message-ID: <20150927223715.7364a1e1@urahara>
References: <1443175110-23498-1-git-send-email-bst@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	trivial@kernel.org, kernel@pengutronix.de
To: Bastian Stender <bst@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35165 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730AbbI1FhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 01:37:06 -0400
Received: by pacfv12 with SMTP id fv12so167387670pac.2
        for <netdev@vger.kernel.org>; Sun, 27 Sep 2015 22:37:06 -0700 (PDT)
In-Reply-To: <1443175110-23498-1-git-send-email-bst@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Sep 2015 11:58:30 +0200
Bastian Stender <bst@pengutronix.de> wrote:

>  
>  #ifdef IPCONFIG_DEBUG
> -#define DBG(x) printk x
> +#define DBG(x) pr_debug(x)
>  #else
>  #define DBG(x) do { } while(0)
>  #endif

Why not remove all the local IPCONFIG_DEBUG stuff and just use pr_debug()
like modern kernel code.
