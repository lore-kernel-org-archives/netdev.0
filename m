From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] ipmr: fix possible race resulting from improper
 usage of IP_INC_STATS_BH() in preemptible context.
Date: Sun, 01 Nov 2015 14:35:00 -0800
Message-ID: <1446417300.6254.91.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.OSX.2.00.1510291646320.59200@animac.local>
	 <20151030001510.GG18062@breakpoint.cc>
	 <alpine.OSX.2.00.1510291841480.68875@animac.local>
	 <1446178542.6254.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151030103658.GA25931@breakpoint.cc>
	 <1446201624.707140.424480297.4D8B55D6@webmail.messagingengine.com>
	 <20151030104846.GA3461@breakpoint.cc>
	 <1446202828.6254.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAOxq_8Nd8KA8CpwVPtCr2gwDbfzsqRp586PddF7r5DSSmeHb6A@mail.gmail.com>
	 <1446232356.6254.23.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.OSX.2.00.1510301651240.81585@animac.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ani Sinha <ani@anirban.org>, fruggeri <fruggeri@arista.com>
To: Ani Sinha <ani@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35041 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753218AbbKAWfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 17:35:03 -0500
Received: by pasz6 with SMTP id z6so127310915pas.2
        for <netdev@vger.kernel.org>; Sun, 01 Nov 2015 14:35:02 -0800 (PST)
In-Reply-To: <alpine.OSX.2.00.1510301651240.81585@animac.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-30 at 16:54 -0700, Ani Sinha wrote:
> Fixes the following kernel BUG :

> Signed-off-by: Ani Sinha <ani@arista.com>
> ---
>  net/ipv4/ipmr.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
