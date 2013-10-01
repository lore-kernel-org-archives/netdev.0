From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 3/3] net: ipv4 only populate IP_PKTINFO when needed
Date: Tue, 01 Oct 2013 13:42:30 -0700
Message-ID: <1380660150.19002.34.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380656025-8847-1-git-send-email-sbohrer@rgmadvisors.com>
	 <1380656025-8847-4-git-send-email-sbohrer@rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tomk@rgmadvisors.com,
	netdev <netdev@vger.kernel.org>
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:48051 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751898Ab3JAUmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 16:42:32 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro12so7640686pbb.41
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 13:42:31 -0700 (PDT)
In-Reply-To: <1380656025-8847-4-git-send-email-sbohrer@rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-01 at 14:33 -0500, Shawn Bohrer wrote:

> -void ipv4_pktinfo_prepare(struct sk_buff *skb)
> +void ipv4_pktinfo_prepare(struct sock *sk, struct sk_buff *skb)


Seems good to me, could you use :

void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb)
