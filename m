From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3] tcp: bind() use stronger condition for
 bind_conflict
Date: Fri, 13 Apr 2012 10:53:11 +0200
Message-ID: <1334307191.5300.8793.camel@edumazet-glaptop>
References: <1334305305-19952-1-git-send-email-alex.mihai.c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, fbl@redhat.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, Daniel Baluta <dbaluta@ixiacom.com>
To: Alexandru Copot <alex.mihai.c@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:61513 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932789Ab2DMIxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 04:53:17 -0400
Received: by wejx9 with SMTP id x9so1774053wej.19
        for <netdev@vger.kernel.org>; Fri, 13 Apr 2012 01:53:16 -0700 (PDT)
In-Reply-To: <1334305305-19952-1-git-send-email-alex.mihai.c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-13 at 11:21 +0300, Alexandru Copot wrote:
> From: Alex Copot <alex.mihai.c@gmail.com>
> 
> We must try harder to get unique (addr, port) pairs when
> doing port autoselection for sockets with SO_REUSEADDR
> option set.

...

>  			}
> +			if (!relax && reuse && sk2->sk_reuse &&
> +			   sk2->sk_state != TCP_LISTEN) {
> +				const __be32 sk2_rcv_saddr = sk_rcv_saddr(sk2);
> +


Oh well, missing space here :(

I said :

if (condition_one ||
    condition_two) {

not

if (condition_one ||
   condition_two) {



Signed-off-by: Eric Dumazet <edumazet@google.com>

Thanks
