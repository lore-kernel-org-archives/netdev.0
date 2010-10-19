From: David Miller <davem@davemloft.net>
Subject: Re: Linux 2.6.35/TIPC 2.0 ABI breaking changes
Date: Tue, 19 Oct 2010 01:16:49 -0700 (PDT)
Message-ID: <20101019.011649.71113115.davem@davemloft.net>
References: <4CBCD429.8090306@windriver.com>
	<20101018234547.GA5703@hmsreliant.think-freely.org>
	<20101019021657.GZ8781@llucax.com.ar>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, paul.gortmaker@windriver.com,
	jon.maloy@ericsson.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: luca@llucax.com.ar
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46220
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932257Ab0JSIQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 04:16:26 -0400
In-Reply-To: <20101019021657.GZ8781@llucax.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leandro Lucarella <luca@llucax.com.ar>
Date: Mon, 18 Oct 2010 23:16:57 -0300

> 
> The problem is not between the tipc stacks in different hosts, is
> between the tipc stack and the applications using it (well, maybe
> there is a problem somewhere else too).
> 
> This was a deliberate API change, not a subtle bug...

Neil et al., if these packets live only between the kernel stack
and the userspace API layer, we should not be byte-swapping this
stuff and we need to fix this fast.

Thanks.
