From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/7] 8139cp: Improve accuracy of cp_interrupt() return,
 to survive IRQ storms
Date: Thu, 24 Sep 2015 00:44:28 +0200
Message-ID: <20150923224427.GA7833@electric-eye.fr.zoreil.com>
References: <1442843991.7367.4.camel@infradead.org>
 <1442844109.7367.5.camel@infradead.org>
 <20150922.164522.1769837358584981735.davem@davemloft.net>
 <1442996049.36485.32.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48190 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755117AbbIWWr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 18:47:26 -0400
Content-Disposition: inline
In-Reply-To: <1442996049.36485.32.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> :
[...]
> But sure, for now I'll drop this from the series and I can try to
> convince you separately.

You may as well change the IRQ storm avoidance logic so that it does not
require conformant driver code if you do not want to waste more time :o)

-- 
Ueimor
