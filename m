From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hamradio: Resolve memory leak due to missing firmware
 release in add_mcs()
Date: Sun, 09 Jan 2011 15:46:15 -0800 (PST)
Message-ID: <20110109.154615.200375094.davem@davemloft.net>
References: <alpine.LNX.2.00.1101062146430.13988@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org, jpr@f6fbb.org, frible@teaser.fr,
	sailer@ife.ee.ethz.ch
To: jj@chaosbits.net
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1101062146430.13988@swampdragon.chaosbits.net>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Thu, 6 Jan 2011 21:50:29 +0100 (CET)

> 
> Failure to release_firmware() in drivers/net/hamradio/yam.c::add_mcs() 
> causes memory leak.
> This patch should fix it.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Applied.
