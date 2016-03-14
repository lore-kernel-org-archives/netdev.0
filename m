From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] batman-adv: Less function calls in
 batadv_is_ap_isolated() after error detection
Date: Mon, 14 Mar 2016 15:25:02 -0400 (EDT)
Message-ID: <20160314.152502.1823929263984045274.davem@davemloft.net>
References: <564EFC67.7050307@users.sourceforge.net>
	<1655341.WCvHHx7pqD@bentobox>
	<56E2BCD8.9010200@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	a@unstable.cc, mareklindner@neomailbox.ch, sw@simonwunderlich.de,
	sven@narfation.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <56E2BCD8.9010200@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 11 Mar 2016 13:40:56 +0100

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Fri, 11 Mar 2016 13:10:20 +0100
> 
> The variables "tt_local_entry" and "tt_global_entry" were eventually
> checked again despite of a corresponding null pointer test before.
> 
> * Avoid this double check by reordering a function call sequence
>   and the better selection of jump targets.
> 
> * Omit the initialisation for these variables at the beginning then.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

I am assuming Antonio will take this in via his tree.
