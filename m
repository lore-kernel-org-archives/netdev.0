From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] netlink: extend buffers to 16K
Date: Wed, 29 Oct 2014 22:52:33 -0700
Message-ID: <20141029225233.68db3433@urahara>
References: <1413045793.9362.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:42845 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060AbaJ3Fwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 01:52:43 -0400
Received: by mail-pd0-f181.google.com with SMTP id y10so4457686pdj.40
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 22:52:43 -0700 (PDT)
In-Reply-To: <1413045793.9362.48.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 11 Oct 2014 09:43:13 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Starting from linux-3.15 (commit 9063e21fb026, "netlink: autosize skb
> lengths"), kernel is able to send up to 16K in netlink replies.
> 
> This change enables iproute2 commands to get bigger chunks,
> without breaking compatibility with old kernels.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
