From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Wed, 3 Jun 2009 08:01:24 +0000
Message-ID: <20090603080123.GA5644@ff.dom.local>
References: <298f5c050906020445n3941b4ceic1167a4a028005bf@mail.gmail.com> <20090602123635.GC4239@ff.dom.local> <4A251EEE.4060903@trash.net> <20090602130857.GA7690@ff.dom.local> <4A252714.2020008@trash.net> <20090602213723.GB2850@ami.dom.local> <4A259EB2.5010500@gmail.com> <4A2620FD.8030708@trash.net> <20090603074049.GA5254@ff.dom.local> <4A262BE7.4090807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antonio Almeida <vexwek@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:34636 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755214AbZFCIB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 04:01:29 -0400
Received: by bwz22 with SMTP id 22so8496723bwz.37
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2009 01:01:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A262BE7.4090807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2009 at 09:53:11AM +0200, Patrick McHardy wrote:
...
> Yes, it would work perfectly fine with usecs, which is actually (and
> unfortunately) the unit it uses in its ABI. But I think its better
> to convert the values once during initialization, instead of again
> and again when scheduling the watchdog. The necessary changes are
> really trivial, all you need to do when changing the scaling factors
> is to increase SM_MASK and decrease ISM_MASK accordingly.

Right! (On the other hand we could consider a separate watchdog too...)

Jarek P.
