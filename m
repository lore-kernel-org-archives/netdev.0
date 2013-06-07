From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2] get_rate: detect 32bit overflows
Date: Fri, 7 Jun 2013 09:25:45 -0700
Message-ID: <20130607092545.21cd79ef@nehalam.linuxnetplumber.net>
References: <1370199083.24311.43.camel@edumazet-glaptop>
	<1370209008.24311.91.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:50555 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756549Ab3FGQZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 12:25:49 -0400
Received: by mail-pd0-f177.google.com with SMTP id u10so4966336pdi.22
        for <netdev@vger.kernel.org>; Fri, 07 Jun 2013 09:25:49 -0700 (PDT)
In-Reply-To: <1370209008.24311.91.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 02 Jun 2013 14:36:48 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Current rate limit is 34.359.738.360 bit per second, and
> unfortunately 40Gbps links are above it.
> 
> overflows in get_rate() are currently not detected, and some
> users are confused. Let's detect this and complain.
> 
> Note that some qdisc are ready to get extended range, but this will
> need additional attributes and new iproute2
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied
