From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] net: fix can_checksum_protocol() arguments swap
Date: Wed, 19 Jan 2011 05:33:25 -0800
Message-ID: <AANLkTi=sJGFPNkzG9sDDjiREsRXVj8U_rWNr6sWvhX-e@mail.gmail.com>
References: <1295434296.3273.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Hans de Bruin <jmdebruin@xmsnet.nl>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:39488 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753705Ab1ASNd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 08:33:26 -0500
Received: by iyj18 with SMTP id 18so811086iyj.19
        for <netdev@vger.kernel.org>; Wed, 19 Jan 2011 05:33:25 -0800 (PST)
In-Reply-To: <1295434296.3273.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 19, 2011 at 2:51 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> commit 0363466866d901fbc (net offloading: Convert checksums to use
> centrally computed features.) mistakenly swapped can_checksum_protocol()
> arguments.
>
> This broke IPv6 on bnx2 for instance, on NIC without TCPv6 checksum
> offloads.
>
> Reported-by: Hans de Bruin <jmdebruin@xmsnet.nl>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Jesse Gross <jesse@nicira.com>
> ---
> I cant believe I spent so much time on this bug.

Thanks Eric, I was staring at this code and I can't believe that I
didn't see it.

Acked-by: Jesse Gross <jesse@nicira.com>
