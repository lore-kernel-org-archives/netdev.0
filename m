From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] qdisc: allow setting default queuing discipline
Date: Tue, 27 Aug 2013 21:00:48 -0700
Message-ID: <1377662448.8828.155.camel@edumazet-glaptop>
References: <20130827161908.26062336@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:54249 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784Ab3H1EAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 00:00:50 -0400
Received: by mail-pa0-f45.google.com with SMTP id bg4so5688266pad.4
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 21:00:49 -0700 (PDT)
In-Reply-To: <20130827161908.26062336@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-27 at 16:19 -0700, Stephen Hemminger wrote:
> By default, the pfifo_fast queue discipline has been used by default
> for all devices. But we have better choices now.
> 
> This patch allow setting the default queueing discipline with sysctl.
> This allows easy use of better queueing disciplines on all devices
> without having to use tc qdisc scripts. It is intended to allow
> an easy path for distributions to make fq_codel or sfq the default
> qdisc.
> 
> This patch also makes pfifo_fast more of a first class qdisc, since
> it is now possible to manually override the default and explicitly
> use pfifo_fast. The behavior for systems who do not use the sysctl
> is unchanged, they still get pfifo_fast
> 
> Also removes leftover random # in sysctl net core.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> ---

I find this quite incredible, because I was going to write such patch
tonight ;)

Now I can just relax, thanks so much Stephen !

Acked-by: Eric Dumazet <edumazet@google.com>
