From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] ipv[4|6]: correct dropwatch false positive
 in local_deliver_finish
Date: Fri, 01 Mar 2013 09:56:44 -0800
Message-ID: <1362160604.15793.57.camel@edumazet-glaptop>
References: <1362159848-8530-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	William Reich <reich@ulticom.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:38306 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202Ab3CAR4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 12:56:46 -0500
Received: by mail-pa0-f47.google.com with SMTP id bj3so1950237pad.6
        for <netdev@vger.kernel.org>; Fri, 01 Mar 2013 09:56:46 -0800 (PST)
In-Reply-To: <1362159848-8530-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-01 at 12:44 -0500, Neil Horman wrote:
> I had a report recently of a user trying to use dropwatch to localise some frame
> loss, and they were getting false positives.  Turned out they were using a user
> space SCTP stack that used raw sockets to grab frames.  When we don't have a
> registered protocol for a given packet, we record it as a drop, even if a raw
> socket receieves the frame.  We should only record the drop in the event a raw
> socket doesnt exist to receive the frames
> 
> Tested by the reported successfully
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: William Reich <reich@ulticom.com>
> Tested-by: William Reich <reich@ulticom.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: William Reich <reich@ulticom.com>
> CC: eric.dumazet@gmail.com
> ---
>  net/ipv4/ip_input.c  | 6 ++++--
>  net/ipv6/ip6_input.c | 6 ++++--
>  2 files changed, 8 insertions(+), 4 deletions(-)

Thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
