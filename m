From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next v3 1/3] udp: Expand UDP tunnel common APIs
Date: Tue, 26 Aug 2014 20:54:07 -0700
Message-ID: <1409111647.3173.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1409110530-4383-1-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:37736 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753373AbaH0DyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 23:54:09 -0400
Received: by mail-pd0-f169.google.com with SMTP id y10so23907660pdj.28
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 20:54:08 -0700 (PDT)
In-Reply-To: <1409110530-4383-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-08-26 at 20:35 -0700, Andy Zhou wrote:
> Added create_udp_tunnel_socket(), packet receive and transmit,  and
> other related common functions for UDP tunnels.
> 
> Per net open UDP tunnel ports are tracked in this common layer to
> prevent sharing of a single port with more than one UDP tunnel.
> 
> Signed-off-by: Andy Zhou <azhou@nicira.com>
> ---

I see some RCU code, but I do not see elementary rules of RCU being
respected in this patch.

Changelogs are a bit terse, and there is not a single comment in this
code.

What is going on exactly ?
