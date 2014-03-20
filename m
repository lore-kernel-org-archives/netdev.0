From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2] tcp: syncookies: do not use getnstimeofday()
Date: Thu, 20 Mar 2014 09:45:27 +0100
Message-ID: <20140320084527.GB5080@breakpoint.cc>
References: <1379709176-1625-1-git-send-email-fw@strlen.de>
 <1395261524.9114.60.camel@edumazet-glaptop2.roam.corp.google.com>
 <1395263181.9114.69.camel@edumazet-glaptop2.roam.corp.google.com>
 <1395288141.9114.82.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:38082 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752962AbaCTIp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 04:45:28 -0400
Content-Disposition: inline
In-Reply-To: <1395288141.9114.82.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> While it is true that getnstimeofday() uses about 40 cycles if TSC
> is available, it can use 1600 cycles if hpet is the clocksource.
> 
> Switch to get_jiffies_64(), as this is more than enough, and
> go back to 60 seconds periods.
> 
> Fixes: 8c27bd75f04f ("tcp: syncookies: reduce cookie lifetime to 128 seconds")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Florian Westphal <fw@strlen.de>

Acked-by: Florian Westphal <fw@strlen.de>
