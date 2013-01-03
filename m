From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] tcp: split tcp_ecn sysctl knob to distinguish
 between IPv4 and IPv6
Date: Thu, 03 Jan 2013 04:47:40 -0800
Message-ID: <1357217260.21409.24224.camel@edumazet-glaptop>
References: <20130103000009.GG4464@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:57240 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237Ab3ACMrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 07:47:42 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so8509236pbc.33
        for <netdev@vger.kernel.org>; Thu, 03 Jan 2013 04:47:42 -0800 (PST)
In-Reply-To: <20130103000009.GG4464@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-03 at 01:00 +0100, Hannes Frederic Sowa wrote:
> ECN could be more reliable when used with IPv6 (I don't have proofs). For
> people who want to try ECN with IPv6 but still have problems connecting
> to destinations because of broken IPv4 routers this switch allows one
> to enable ECN just for IPv6.
> 
> Perhaps ECN could be enabled by default in future.
> 
> No code changes since initial submission, just added documentation.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

It would be nice to make the ecn sysctl per net namespace.

Do you have an idea of how to adapt your patch to get this as well ?
