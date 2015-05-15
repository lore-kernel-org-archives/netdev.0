From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RESEND][PATCH] rocker: fix a neigh entry leak issue
Date: Fri, 15 May 2015 07:23:26 +0200
Message-ID: <20150515052326.GA2043@nanopsycho.orion>
References: <1431665601-15380-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com, sfeldma@gmail.com,
	netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:35343 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200AbbEOFXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 01:23:30 -0400
Received: by wgnd10 with SMTP id d10so97678379wgn.2
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 22:23:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431665601-15380-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, May 15, 2015 at 06:53:21AM CEST, ying.xue@windriver.com wrote:
>Once we get a neighbour through looking up arp cache or creating a
>new one in rocker_port_ipv4_resolve(), the neighbour's refcount is
>already taken. But as we don't put the refcount again after it's
>used, this makes the neighbour entry leaked.
>
>Suggested-by: Eric Dumazet <edumazet@google.com>
>Acked-by: Jiri Pirko <jiri@resnulli.us>
>Acked-by: Eric Dumazet <edumazet@google.com>
>Signed-off-by: Ying Xue <ying.xue@windriver.com>


Acked-by: Jiri Pirko <jiri@resnulli.us>
