From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: tcp: tcp_v6_send_response() should give
 an owner to skb
Date: Thu, 29 Jan 2015 13:31:36 -0800
Message-ID: <1422567096.21689.29.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1422453433.29618.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1422566339.21689.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:37258 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930AbbA2Vbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 16:31:38 -0500
Received: by mail-ie0-f173.google.com with SMTP id tr6so39438388ieb.4
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 13:31:37 -0800 (PST)
In-Reply-To: <1422566339.21689.28.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-29 at 13:18 -0800, Eric Dumazet wrote:
> On Wed, 2015-01-28 at 05:57 -0800, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > RST packets and ACK packets sent on behalf of TIME_WAIT sockets
> > do not have a socket owner currently.
> ...
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > ---
> 
> Please do not apply.
> 
> I forgot about commit 3a7c384ffd57ef5fbd95f48edaa2ca4eb3d9f2ee
> ("ipv4: tcp: unicast_sock should not land outside of TCP stack")
> 
> I need to do this in another way.

Well, no, patch was fine, sorry for the noise.

I have to addresss ipv4 side.
