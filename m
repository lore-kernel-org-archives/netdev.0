From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] drivers/net/sungem.c: gem_remove_one mustn't be
 __devexit
Date: Wed, 21 Dec 2005 18:50:30 -0800 (PST)
Message-ID: <20051221.185030.131647618.davem@davemloft.net>
References: <200512211323.19242.meyer@work.de>
	<20051221132543.GG5359@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: meyer@work.de, akpm@osdl.org, torvalds@osdl.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965044AbVLVCuk@vger.kernel.org>
To: bunk@stusta.de
In-Reply-To: <20051221132543.GG5359@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Wed, 21 Dec 2005 14:25:43 +0100

> gem_remove_one() is called from the __devinit gem_init_one().
> 
> Therefore, gem_remove_one() mustn't be __devexit.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Looks good, applied, thanks Adrian.
