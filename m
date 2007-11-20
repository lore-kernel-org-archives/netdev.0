From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] LRO ack aggregation
Date: Tue, 20 Nov 2007 16:35:09 +0300
Message-ID: <20071120133509.GA17377@2ka.mipt.ru>
References: <E1IuMIQ-0003gc-00@gondolin.me.apana.org.au> <20071119.222214.81458569.davem@davemloft.net> <4742C96D.3050203@myri.com> <20071120.035558.214794900.davem@davemloft.net> <4742E0A9.2070205@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, ossthema@de.ibm.com
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:37163 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751530AbXKTNfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 08:35:46 -0500
Content-Disposition: inline
In-Reply-To: <4742E0A9.2070205@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Tue, Nov 20, 2007 at 08:27:05AM -0500, Andrew Gallatin (gallatin@myri.com) wrote:
> Hmm.. rather than a global tunable, what if it was a
> network driver managed tunable which toggled a flag in the
> lro_mgr features?  Would that be better?

What about ethtool control to set LRO_simple and LRO_ACK_aggregation?

-- 
	Evgeniy Polyakov
