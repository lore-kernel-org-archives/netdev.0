From: David Miller <davem@davemloft.net>
Subject: Re: stuck tcp connections 2.6.26-rc7
Date: Wed, 25 Jun 2008 15:24:47 -0700 (PDT)
Message-ID: <20080625.152447.178284093.davem@davemloft.net>
References: <dd18b0c30806241303g755e3881y4ea7d403eb2922fc@mail.gmail.com>
	<dd18b0c30806242325j4f6d1b1bw1cdde7ea08ad12e2@mail.gmail.com>
	<2c0942db0806250816r123affb4x4ef17f4773180a10@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: justinmattock@gmail.com, didier@raboud.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: ray-lk@madrabbit.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59500
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754303AbYFYWYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 18:24:47 -0400
In-Reply-To: <2c0942db0806250816r123affb4x4ef17f4773180a10@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ray Lee" <ray-lk@madrabbit.org>
Date: Wed, 25 Jun 2008 08:16:20 -0700

> On my system, I've noticed that the flashplugin can manage to starve
> other processes in a pure scheduler sort of way, so you might try
> running latencytop to see if there's some sort of issue there. OTOH,
> I've noticed firefox itself hang for 3-15 seconds in the middle of a
> read (just as you describe), with nothing else going on in the system,
> so <shrug>. I've been blaming firefox, but I could be wrong.

See if firefox is stuck in disk wait when things get wedged like
this.
