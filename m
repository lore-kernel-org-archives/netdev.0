From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: [PATCH] Rate should be u64 to avoid integer overflow at high
 speeds (>= ~35Gbit)
Date: Wed, 13 Mar 2013 10:57:42 -0600
Message-ID: <5140B006.500@genband.com>
References: <1362885604-14006-1-git-send-email-j.vimal@gmail.com>	<1362888229.4051.2.camel@edumazet-glaptop>	<CAK3Ji11Mij3Y_sGC6nLS01rxfccZo0SPJmQy-LAmskz1OEdmkQ@mail.gmail.com>	<1362891937.4051.25.camel@edumazet-glaptop>	<20130310004904.de508bfa.billfink@mindspring.com>	<1362894876.4051.27.camel@edumazet-glaptop>	<513F3BE1.2080409@genband.com>	<20130312154245.GA13101@casper.infradead.org>	<20130313020156.c9dd9841.billfink@mindspring.com>	<1363155195.13690.48.camel@edumazet-glaptop>	<20130313112950.f3a4a332.billfink@mindspring.com> <20130313083400.2329e982@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bill Fink <billfink@mindspring.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Thomas Graf <tgraf@suug.ch>, Vimal <j.vimal@gmail.com>,
	netdev@vger.kernel.org, shemminger <shemminger@vyatta.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og103.obsmtp.com ([64.18.2.159]:42939 "EHLO
	exprod7og103.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933179Ab3CMQ6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 12:58:41 -0400
In-Reply-To: <20130313083400.2329e982@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2013 09:34 AM, Stephen Hemminger wrote:

> As others have said the multiplier shift approach is a not a workable
> solution because it is likely to cause too many compatibility surprises.
> Older kernels would ignore the multiplier and therefore not give the users
> the effective rate they wanted.

How is that any different than ignoring the 64-bit value and not giving 
the effective rate they wanted?

Chris
