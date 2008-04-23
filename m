From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: LRO/GSO interaction when packets are forwarded
Date: Wed, 23 Apr 2008 11:09:43 +0000
Message-ID: <20080423110942.GC3994@ff.dom.local>
References: <20080423061538.GB3946@ff.dom.local> <20080423100702.GS21637@solarflare.com> <20080423103809.GB3994@ff.dom.local> <20080423.034225.176998769.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, stephen.hemminger@vyatta.com,
	kmansley@solarflare.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:59121 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbYDWLGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 07:06:52 -0400
Received: by nf-out-0910.google.com with SMTP id g13so970565nfb.21
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2008 04:06:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080423.034225.176998769.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2008 at 03:42:25AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Wed, 23 Apr 2008 10:38:10 +0000
> 
> > Thanks for explanation! I'd still like to know why it's wrong, and
> > why we should turn this off on a device with ip_forwarding enabled
> > without checking how smart this hardware is?
> 
> It's not about how smart the hardware is.

...I think Stephen mentioned there could be some difference?

> 
> This a stateless feature, the device accumulates data into
> large receive frames when it's TCP and the ports and addresses
> match.
> 
> There is no knowledge of routes or anything like that, nor should
> there be, because otherwise it would cease to be stateless.

OK, but bridging doesn't seem to need much more... But, anyway, why
(with such a smart hardware) it should be impossible to get such
local LRO packets, and do ip forwarding (with non-LRO non-local
packets)?

Thanks,
Jarek P.
