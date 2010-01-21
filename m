From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sky2: Fix WARNING: at lib/dma-debug.c:902 check_sync
Date: Thu, 21 Jan 2010 22:02:21 +0100
Message-ID: <20100121210221.GA3448@del.dom.local>
References: <20100120094103.GA6225@ff.dom.local>
 <4B58B217.8030001@majjas.com>
 <20100121204133.GB3085@del.dom.local>
 <4B58BD3A.1000705@majjas.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:57507 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755188Ab0AUVC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 16:02:27 -0500
Content-Disposition: inline
In-Reply-To: <4B58BD3A.1000705@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 21, 2010 at 03:46:50PM -0500, Michael Breuer wrote:
> On 1/21/2010 3:41 PM, Jarek Poplawski wrote:
> >On Thu, Jan 21, 2010 at 02:59:19PM -0500, Michael Breuer wrote:
> >>Test notes:
> >>
> >>1) Warning previously apparent on start (dma_debug check_sync) with
> >>CONFIG_DMAR=n is gone.
> >>2) W/o the above patch, I was getting sky2 DMAR errors and
> >>subsequent TX hangs requiring reboot to clear. The hangs happened
> >>after at least 12 hours of uptime, and under RX load at the time of
> >>the hang.
> >>3) With the above patch (and no other changes) I have not been able
> >>to recreate the crash - the system is stable.
> >Btw, could you remind us if during last dmar bugs jumbo frames might
> >have been used or maybe mtu was changed, and the current test setting?
> >
> I've hit this with and without Jumbo frames enabled. Last couple of
> recreations were with mtu = 1500, which is how I'm running now.
> >>I have been following the discussion about the DMA api would suggest
> >>that the length issue when DMAR is enabled is less innocuous than
> >>previously believed.
> >Actually, the last conclusions are - it's more innocuous than ever
> >believed, and I completely agree with this (at least until the next
> >week ;-).
> I stand grammatically corrected.

I didn't mean anything grammatical, sorry! (Except, it's equally
complex ;-)

Jarek P.
