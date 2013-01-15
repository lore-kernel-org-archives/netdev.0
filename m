From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 rx_missed increasing in bursts (regression)
Date: Tue, 15 Jan 2013 23:53:16 +0100
Message-ID: <20130115225316.GA924@electric-eye.fr.zoreil.com>
References: <20130108102814.7abe8c08@vostro> <20130108225833.GA4193@electric-eye.fr.zoreil.com> <20130109115850.055b7a7e@vostro> <20130109191456.0888ac75@vostro> <20130115101114.0a59a7cb@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41204 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933835Ab3AOXVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 18:21:50 -0500
Content-Disposition: inline
In-Reply-To: <20130115101114.0a59a7cb@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Teras <timo.teras@iki.fi> :
[...]
> Would it be feasible to make the fifo size a module parameter, or
> somehow autotuned according to available system memory?

If by fifo size you mean descriptor ring size, I can do it through ethtool.

> I also noticed that since recent commits, the dirty_rx is always
> identical cur_rx. Basically, dirty_rx can be just removed. Should I
> send a patch for this?

Yes, please.

-- 
Ueimor
