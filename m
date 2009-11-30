From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net 02/05: fib_rules: rename ifindex/ifname/FRA_IFNAME to iifindex/iifname/FRA_IIFNAME
Date: Mon, 30 Nov 2009 21:21:21 +0100
Message-ID: <4B142941.2020302@gmail.com>
References: <20091130175529.7555.10132.sendpatchset@x2.localnet> <20091130175532.7555.11857.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:55231 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903AbZK3UVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 15:21:32 -0500
Received: by bwz27 with SMTP id 27so2904094bwz.21
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2009 12:21:37 -0800 (PST)
In-Reply-To: <20091130175532.7555.11857.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote, On 11/30/2009 06:55 PM:

> commit dc4427ae3647195508b4df883050a9f0ef111165
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Mon Nov 30 15:54:05 2009 +0100
> 
>     net: fib_rules: rename ifindex/ifname/FRA_IFNAME to iifindex/iifname/FRA_IIFNAME
>     
>     The next patch will add oif classification, rename interface related members
>     and attributes to reflect that they're used for iif classification.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
> index c7e5b70..e3c91af 100644
> --- a/include/linux/fib_rules.h
> +++ b/include/linux/fib_rules.h
> @@ -8,7 +8,8 @@
>  #define FIB_RULE_PERMANENT	0x00000001
>  #define FIB_RULE_INVERT		0x00000002
>  #define FIB_RULE_UNRESOLVED	0x00000004
> -#define FIB_RULE_DEV_DETACHED	0x00000008
> +#define FIB_RULE_IIF_DETACHED	0x00000008
> +#define FIB_RULE_DEV_DETACHED	FIB_RULE_DEV_DETACHED

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Is it some trick?

Jarek P.
