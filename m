From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Rate should be u64 to avoid integer overflow at high
 speeds (>= ~35Gbit)
Date: Tue, 12 Mar 2013 16:44:28 +0100
Message-ID: <1363103068.13690.11.camel@edumazet-glaptop>
References: <1362885604-14006-1-git-send-email-j.vimal@gmail.com>
	 <1362888229.4051.2.camel@edumazet-glaptop>
	 <CAK3Ji11Mij3Y_sGC6nLS01rxfccZo0SPJmQy-LAmskz1OEdmkQ@mail.gmail.com>
	 <1362891937.4051.25.camel@edumazet-glaptop>
	 <20130310004904.de508bfa.billfink@mindspring.com>
	 <1362894876.4051.27.camel@edumazet-glaptop> <513F3BE1.2080409@genband.com>
	 <20130312154245.GA13101@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <chris.friesen@genband.com>,
	Bill Fink <billfink@mindspring.com>, Vimal <j.vimal@gmail.com>,
	netdev@vger.kernel.org, shemminger <shemminger@vyatta.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:49750 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932122Ab3CLPoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 11:44:32 -0400
Received: by mail-ea0-f180.google.com with SMTP id j14so1771013eak.39
        for <netdev@vger.kernel.org>; Tue, 12 Mar 2013 08:44:31 -0700 (PDT)
In-Reply-To: <20130312154245.GA13101@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-12 at 15:42 +0000, Thomas Graf wrote:

> The introduction of a shift operator or multiplier introduces
> inprecision. I'd much rather see new 64bit Netlink attributes
> that, if present, replace the old rate values and statistics.
> 
> You will need to add a new Netlink attribute anyway and we might
> as well transfer the actual rate instead of a multiplier. Just
> like we did with IFLA_STATS64.

Thanks Thomas !
