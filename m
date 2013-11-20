From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few
 KB/s
Date: Wed, 20 Nov 2013 09:50:37 +0100
Message-ID: <20131120095037.07dc6fc0@skate>
References: <87a9hagex1.fsf@natisbad.org>
	<20131112100126.GB23981@1wt.eu>
	<87vbzxd473.fsf@natisbad.org>
	<20131113072257.GB10591@1wt.eu>
	<20131117141940.GA18569@1wt.eu>
	<1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
	<87li0kkhzx.fsf@natisbad.org>
	<1384869194.8604.92.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119174323.GH913@1wt.eu>
	<1384885910.8604.110.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119184121.GN913@1wt.eu>
	<874n780wzc.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, Eric Dumazet <eric.dumazet@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	simon.guinot@sequanux.org, netdev@vger.kernel.org,
	edumazet@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: arno@natisbad.org (Arnaud Ebalard)
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:50969 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750858Ab3KTIuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 03:50:40 -0500
In-Reply-To: <874n780wzc.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnaud,

On Wed, 20 Nov 2013 00:53:43 +0100, Arnaud Ebalard wrote:

>  - It seems I will I have to spend some time on the SATA issues I
>    previously thought were an artefact of not cleaning my tree during a
>    debug session [1], i.e. there is IMHO an issue.

I don't remember in detail what your SATA problem was, but just to let
you know that we are currently debugging a problem that occurs on
Armada XP (more than one core is needed for the problem to occur), with
SATA (the symptom is that after some time of SATA usage, SATA traffic is
stalled, and no SATA interrupts are generated anymore). We're still
working on this one, and trying to figure out where the problem is.

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
