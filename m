From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/3] ethernet: Add new driver for Marvell Armada 375
 network unit
Date: Mon, 7 Jul 2014 23:22:07 +0200
Message-ID: <20140707212207.GB16677@electric-eye.fr.zoreil.com>
References: <1404498697-21978-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1404498697-21978-2-git-send-email-ezequiel.garcia@free-electrons.com>
 <20140705210359.GA19441@electric-eye.fr.zoreil.com>
 <20140707142653.GA18910@arch.cereza>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Marcin Wojtas <mw@semihalf.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>, joe@perches.com
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38170 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbaGGVWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 17:22:49 -0400
Content-Disposition: inline
In-Reply-To: <20140707142653.GA18910@arch.cereza>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ezequiel Garcia <ezequiel.garcia@free-electrons.com> :
[...]
> Hm, yes, I see what you mean. These names bother me too, and I think we could
> probably change it so "pp2" is "dev", and "pp" is "port". But on the other
> side, I'm not sure it's worth doing such an intrusive change just to fix these
> names.
> 
> What do you think ?

Yike. Please don't substitute "pp2" with some "dev": it's a "priv" more than
a "dev". s/pp/port/ would be good enough. Your call.

-- 
Ueimor
