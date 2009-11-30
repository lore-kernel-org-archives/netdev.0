From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net 03/05: fib_rules: add oif classification
Date: Mon, 30 Nov 2009 23:31:57 +0100
Message-ID: <4B1447DD.1070904@gmail.com>
References: <20091130175529.7555.10132.sendpatchset@x2.localnet> <20091130175533.7555.35189.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:64862 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993AbZK3Wb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 17:31:57 -0500
Received: by bwz27 with SMTP id 27so2999647bwz.21
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2009 14:32:02 -0800 (PST)
In-Reply-To: <20091130175533.7555.35189.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote, On 11/30/2009 06:55 PM:

> commit b3fe9e6465a572e97dc1bb6222c1ec4224285817
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Mon Nov 30 16:00:51 2009 +0100
> 
>     net: fib_rules: add oif classification

...

> diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
> index 62bebcb..d4e875a 100644
> --- a/include/net/fib_rules.h
> +++ b/include/net/fib_rules.h
> @@ -11,6 +11,7 @@ struct fib_rule {
>  	struct list_head	list;
>  	atomic_t		refcnt;
>  	int			iifindex;
> +	int			oifindex;

Doesn't it "break" the cacheline fix from 01/05?

Jarek P.

>  	u32			mark;
>  	u32			mark_mask;
>  	u32			pref;
> @@ -20,6 +21,7 @@ struct fib_rule {
>  	u32			target;
>  	struct fib_rule *	ctarget;
>  	char			iifname[IFNAMSIZ];
> +	char			oifname[IFNAMSIZ];
>  	struct rcu_head		rcu;
>  	struct net *		fr_net;
>  };

