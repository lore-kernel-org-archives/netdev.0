From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.31-rc9] mv643xx_eth.c: remove unused txq_set_wrr()
Date: Fri, 11 Sep 2009 12:37:11 -0700 (PDT)
Message-ID: <20090911.123711.04912729.davem@davemloft.net>
References: <200909070959.n879xGui019854@pilspetsen.it.uu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@marvell.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: mikpe@it.uu.se
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756180AbZIKTg4@vger.kernel.org>
In-Reply-To: <200909070959.n879xGui019854@pilspetsen.it.uu.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mikael Pettersson <mikpe@it.uu.se>
Date: Mon, 7 Sep 2009 11:59:16 +0200 (MEST)

> The txq_set_wrr() function in drivers/net/mv643xx_eth.c is
> unused, not even referenced under #if 0 or something like that,
> which results in a compile-time warning:
> 
> drivers/net/mv643xx_eth.c:1070: warning: 'txq_set_wrr' defined but not used
> 
> Fix: remove it.
> 
> Signed-off-by: Mikael Pettersson <mikpe@it.uu.se>

Applied.
