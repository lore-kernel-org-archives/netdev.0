From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/5] soreuseport: infrastructure
Date: Tue, 15 Jan 2013 07:53:23 -0800
Message-ID: <20130115075323.64b2fdc7@nehalam.linuxnetplumber.net>
References: <alpine.DEB.2.00.1301141152130.3433@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	netdev@markandruth.co.uk, eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:38257 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755137Ab3AOPyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 10:54:52 -0500
Received: by mail-pb0-f43.google.com with SMTP id um15so116402pbc.30
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 07:54:52 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1301141152130.3433@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Jan 2013 12:00:18 -0800 (PST)
Tom Herbert <therbert@google.com> wrote:

> +/* Pseudo random number generator from numerical recipes. */
> +static inline u32 next_pseudo_random32(u32 seed)
> +{
> +	return seed * 1664525 + 1013904223;
> +}
> +

Don't reimplement a pseudo random number generator, there already
exists net_random() 
