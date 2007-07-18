From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/3] [net/core] move dev_mc_discard from dev_mcast.c to
 dev.c
Date: Wed, 18 Jul 2007 12:01:38 +0200
Message-ID: <469DE502.8070800@trash.net>
References: <11846606051099-git-send-email-crquan@gmail.com>	 <11847264651509-git-send-email-crquan@gmail.com>	 <20070718.021107.40833440.davem@davemloft.net> <91b13c310707180259v547ba2b3wc901102d35760a50@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	linux-kernel@vger.kernel.org
To: rae l <crquan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34080 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbXGRKCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 06:02:03 -0400
In-Reply-To: <91b13c310707180259v547ba2b3wc901102d35760a50@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rae l wrote:
> All in one word, I don't think the single file dev_mcast.c is needed
> anymore.


Agreed. But dev.c is growing larger and larger, maybe dev_addr.c?
Or dev_config.c, with some of the other device configuration functions?
