From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: have ipconfig not wait if no dev is available
Date: Tue, 20 Dec 2011 14:09:42 -0500 (EST)
Message-ID: <20111220.140942.650965480515835433.davem@davemloft.net>
References: <1324371484-24082-1-git-send-email-gerlando.falauto@keymile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: micha@neli.hopto.org, holger.brunck@keymile.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: gerlando.falauto@keymile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1324371484-24082-1-git-send-email-gerlando.falauto@keymile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerlando Falauto <gerlando.falauto@keymile.com>
Date: Tue, 20 Dec 2011 09:58:04 +0100

> previous commit 3fb72f1e6e6165c5f495e8dc11c5bbd14c73385c
> makes IP-Config wait for carrier on at least one network device.
> 
> Before waiting (predefined value 120s), check that at least one device
> was successfully brought up. Otherwise (e.g. buggy bootloader
> which does not set the MAC address) there is no point in waiting
> for carrier.
> 
> Cc: Micha Nelissen <micha@neli.hopto.org>
> Cc: Holger Brunck <holger.brunck@keymile.com>
> Signed-off-by: Gerlando Falauto <gerlando.falauto@keymile.com>

Applied, thanks.
