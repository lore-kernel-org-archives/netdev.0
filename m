From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v3 1/1 net-next] net: fec: add napi support to improve proformance
Date: Fri, 25 Jan 2013 23:23:06 +0100
Message-ID: <20130125222306.GA2523@electric-eye.fr.zoreil.com>
References: <1359077343-8271-1-git-send-email-Frank.Li@freescale.com> <20130125043311.GA4141@ppwaskie-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank Li <Frank.Li@freescale.com>, lznuaa@gmail.com,
	shawn.guo@linaro.org, B38611@freescale.com, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	s.hauer@pengutronix.de
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43864 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753116Ab3AYWww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 17:52:52 -0500
Content-Disposition: inline
In-Reply-To: <20130125043311.GA4141@ppwaskie-mobl2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com> :
[...]
> Also, when you're disabling interrupts above, you're doing that in your
> HW interrupt handler, you should be using spin_lock_irqsave()/irq_restore().

Does the platform forbid to defer FEC_EIR / FEC_IEVENT write to the napi
poll handler and only disable the irq through FEC_EIMR / FEC_IMASK in
fec_enet_interrupt so as to remove the spinlock ?

(Frank, please keep an empty line between variables declarations and
function body).

-- 
Ueimor
