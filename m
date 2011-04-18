From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 :  always copying the rx buffer to new skb
Date: Mon, 18 Apr 2011 20:21:00 +0200
Message-ID: <20110418182100.GA18548@electric-eye.fr.zoreil.com>
References: <4DAC7001.9060800@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com
To: John Lumby <johnlumby@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46110 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621Ab1DRS27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 14:28:59 -0400
Content-Disposition: inline
In-Reply-To: <4DAC7001.9060800@hotmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Lumby <johnlumby@hotmail.com> :
> Summary  -  current r8169 always memcpy's every received buffer to new skb,
>             and I'd like to propose that it should not,
>             which can improve throughput / reduce CPU utilization by
> around 10%

Disclaimer: I'll read your suggestion more carefully when I am back home.
I am late and I could be off-topic.

> I think (not sure) this was related to a bug

Short answer: it's mostly related to CVE-2009-4537 (see git log).

I may resurrect some alternate fix - i.e. detect corrupted Tx descriptors
and reset before things gets wrong - but it is not easy to prove it right
since it may be necessary to tailor it for each member of the 816x / 810x
family. Some input from Realtek may help though.

-- 
Ueimor
