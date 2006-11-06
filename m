From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Pull request for 'jg-20061103-00' tag
Date: Mon, 6 Nov 2006 22:46:29 +0100
Message-ID: <20061106214629.GA29613@electric-eye.fr.zoreil.com>
References: <20061103205606.GA5723@electric-eye.fr.zoreil.com> <454EEBC5.3070408@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:47592 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1753785AbWKFVt0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 16:49:26 -0500
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <454EEBC5.3070408@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jeff@garzik.org> :
[...]
> This warrants much more testing than pushing into 2.6.19-rc4 would give 
> us, so I'm pulling it into #upstream.
> 
> In the past, with 10/100 hubs or ancient Cisco switches, we really 
> didn't want to reset the phy and restart autonegotiation, because that 
> might be problematic.
> 
> In any case, this is a behavior change that may solve problems... but 
> also needs testing to insure that it doesn't also cause problems.

I don't have a single report of a 0x8136 user whose network adapter would
work out of the box without the patch. The sole users of a 0x8136 which I
have heard of need it. See the "r8169 mac address change" thread on l-k
last week. Those users should be able to workaround the issue on 2.6.19
with mii-tool (a bit sucky but...).

Regarding testing, see below.

I have done a quick grep through the l-k mailboxes of these last weeks to
see how much reports included the r8169 module (even in non-r8169 related
bugs of course):
200643: 1
200642: 0
200641: 1 (tainted, smp, preempt)
200640: 0
200639: 0
200638: 0
200637: 0
200636: 1 (Darren Salt, proud 0x8136 user)
200635: 0
200634: 0
200633: 1 (*doh* plain r8169 issue under oom)

Mid august here, i.e. 2 months and a half.

I'll ping known r8169 users, especially those who had link issues in
the past but I can not force them at gunpoint.

If 2.6.19 is more than 2 weeks away, we will probably trade two weeks
of close observation against two months of supplementary delay for no
real stability gain.

Well, MII likes to eat babies anyway. :o/

-- 
Ueimor
