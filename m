From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Rate should be u64 to avoid integer overflow at high
 speeds (>= ~35Gbit)
Date: Sun, 10 Mar 2013 06:54:36 +0100
Message-ID: <1362894876.4051.27.camel@edumazet-glaptop>
References: <1362885604-14006-1-git-send-email-j.vimal@gmail.com>
	 <1362888229.4051.2.camel@edumazet-glaptop>
	 <CAK3Ji11Mij3Y_sGC6nLS01rxfccZo0SPJmQy-LAmskz1OEdmkQ@mail.gmail.com>
	 <1362891937.4051.25.camel@edumazet-glaptop>
	 <20130310004904.de508bfa.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vimal <j.vimal@gmail.com>, netdev@vger.kernel.org,
	shemminger <shemminger@vyatta.com>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:47856 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893Ab3CJFyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 00:54:40 -0500
Received: by mail-ea0-f177.google.com with SMTP id r16so694950ead.22
        for <netdev@vger.kernel.org>; Sat, 09 Mar 2013 21:54:39 -0800 (PST)
In-Reply-To: <20130310004904.de508bfa.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-10 at 00:49 -0500, Bill Fink wrote:

> I don't see the problem.  An old program would not know about
> the new multiplier, would thus get the default multiplier of 1,
> and get the same behavior as always, with the same limitation
> of ~34 Gbps.  But someone with a newer tc/kernel could for example
> specify a multiplier of 10, which would then support rates up to
> about 340 Gbps.  It sounds like a reasonable approach to me.

Hopefully, some of us see the problem here and are able to reject
patches before breaking user land.
