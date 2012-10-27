From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [RFC PATCH net-next] ipv6: remove rt6i_peer_genid from rt6_info
 and its handler
Date: Sat, 27 Oct 2012 18:49:58 +0800
Message-ID: <CAJFZqHzTUD=97485SH29PABGwfUHr3whCn+r5y2px0Z3bkS_1A@mail.gmail.com>
References: <1351256519-7704-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:46764 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736Ab2J0Kt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2012 06:49:59 -0400
Received: by mail-ia0-f174.google.com with SMTP id y32so2792923iag.19
        for <netdev@vger.kernel.org>; Sat, 27 Oct 2012 03:49:59 -0700 (PDT)
In-Reply-To: <1351256519-7704-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sorry for noise, please ignore it, and see version 2

-Roy

2012/10/26  <roy.qing.li@gmail.com>:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> 6431cbc25f(Create a mechanism for upward inetpeer propagation into routes)
> introduces these codes, but this mechanism is never enabled since
> rt6i_peer_genid always is zero whether it is not assigned or assigned by
> rt6_peer_genid(). After 5943634fc5 (ipv4: Maintain redirect and PMTU info
> in struct rtable again), the ipv4 related codes of this mechanism have been
> removed, I think we maybe able to remove them now.
