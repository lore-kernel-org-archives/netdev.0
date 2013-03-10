From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fix buf of assigning skb->tail to
 network_header
Date: Sun, 10 Mar 2013 10:58:48 +0100
Message-ID: <1362909528.4051.32.camel@edumazet-glaptop>
References: <1362908909-45697-1-git-send-email-honkiko@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, zhiguo.hong@emc.com
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:47114 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752732Ab3CJJ6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 05:58:53 -0400
Received: by mail-ee0-f54.google.com with SMTP id c41so1762752eek.13
        for <netdev@vger.kernel.org>; Sun, 10 Mar 2013 01:58:52 -0800 (PST)
In-Reply-To: <1362908909-45697-1-git-send-email-honkiko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-10 at 17:48 +0800, Hong Zhiguo wrote:
> in the case of NET_SKBUFF_DATA_USES_OFFSET,  direct pointer
> assignment to skb->network_header is a dangerous bug.

But skb->tail is not a pointer.

Really you need to explain more than this confusing changelog
