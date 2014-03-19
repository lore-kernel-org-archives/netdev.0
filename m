From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] tcp: syncookies: do not use getnstimeofday()
Date: Wed, 19 Mar 2014 23:56:42 +0100
Message-ID: <20140319225642.GA5080@breakpoint.cc>
References: <1379709176-1625-1-git-send-email-fw@strlen.de>
 <1395261524.9114.60.camel@edumazet-glaptop2.roam.corp.google.com>
 <1395263181.9114.69.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:36493 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753121AbaCSW4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 18:56:44 -0400
Content-Disposition: inline
In-Reply-To: <1395263181.9114.69.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> While it is true that getnstimeofday() uses about 40 cycles if TSC
> is available, it can use 1600 cycles if hpet is the clocksource.

Ouch.  Why is secure_tcp_sequence_number also using
ktime_get_real/getnstimeofday?

clock drift when other cpu is used?

[ Just curious; I have no objections to this patch ]
