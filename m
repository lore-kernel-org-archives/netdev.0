From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Hang: 2.6.32.4 sky2/DMAR (was [PATCH] sky2: Fix WARNING: at
 lib/dma-debug.c:902 check_sync)
Date: Sun, 24 Jan 2010 00:21:33 +0100
Message-ID: <20100123232133.GA3487@del.dom.local>
References: <20100120094103.GA6225@ff.dom.local>
 <4B58B217.8030001@majjas.com>
 <20100121204133.GB3085@del.dom.local>
 <4B59E7EB.3050605@majjas.com>
 <20100122215304.GA3105@del.dom.local>
 <4B5A2362.6000306@majjas.com>
 <20100122230605.GB3105@del.dom.local>
 <4B5A33D8.90501@majjas.com>
 <20100122234656.GC3105@del.dom.local>
 <4B5A39BD.8020305@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	akpm@linux-foundation.org, flyboy@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752842Ab0AWXVn@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B5A39BD.8020305@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 22, 2010 at 06:50:21PM -0500, Michael Breuer wrote:
> When the packets were dropped, there was a different sequence in the
> log - DISCOVER/OFFER repeated. The "normal" is that the sequence
> appeared correct and complete - DISCOVER/OFFER/REQUEST/ACK - or
> INFORM/ACK (vs. INFORM repeatedly sans ACK) as the case may be.

Anyway, I'd be intersted if the switch matters here.

Plus one more test: could you try to load sky2 with the parameter:
"copybreak=1" (the rest as in any recent test, which gave you dmar
errors; any switch).

Thanks,
Jarek P.
