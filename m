From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [net/core] move dev_mc_discard from dev_mcast.c to
 dev.c
Date: Wed, 18 Jul 2007 03:04:40 -0700 (PDT)
Message-ID: <20070718.030440.124084796.davem@davemloft.net>
References: <20070718.021107.40833440.davem@davemloft.net>
	<91b13c310707180259v547ba2b3wc901102d35760a50@mail.gmail.com>
	<469DE502.8070800@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: crquan@gmail.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, linux-kernel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60599
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752260AbXGRKEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 06:04:41 -0400
In-Reply-To: <469DE502.8070800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 18 Jul 2007 12:01:38 +0200

> rae l wrote:
> > All in one word, I don't think the single file dev_mcast.c is needed
> > anymore.
> 
> Agreed. But dev.c is growing larger and larger, maybe dev_addr.c?
> Or dev_config.c, with some of the other device configuration functions?

I don't know, a sizable dev.c is inevitable, allows better refactoring
and consolidation.  And the be honest you're going to have to likely
touch things in dev.c whenever you make changes to dev_addr.c or
whatever you want to name it. :-)

