From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [r8169] About the "PHY reset until link up" warning
Date: Tue, 23 Jul 2013 00:45:43 +0200
Message-ID: <20130722224543.GA6268@electric-eye.fr.zoreil.com>
References: <2215813.0syAhGCZsc@al>
 <20130722214358.GA4997@electric-eye.fr.zoreil.com>
 <20130722.144850.493762080108085770.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lekensteyn@gmail.com, netdev@vger.kernel.org, nic_swsd@realtek.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [92.243.8.30] ([92.243.8.30]:48287 "EHLO violet.fr.zoreil.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751462Ab3GVWpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jul 2013 18:45:54 -0400
Content-Disposition: inline
In-Reply-To: <20130722.144850.493762080108085770.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
> From: Francois Romieu <romieu@fr.zoreil.com>
[...]
> > I can change my mind but I haven't seen much need for a policy
> > change yet.
> 
> In every case where this issue has popped up, we have decided that
> printing messages when the cable is simply unplugged is very
> undesirable.

I could agree if there had not been any progress made with runtime
power management.

> I used to print messages on link failure in all the early drivers I
> wrote, it was a bad decision.

I know something is very wrong when it repeats itself a lot in a PR.

Feel free to take any message silenting patch if someone feels it
worth.

-- 
Ueimor
