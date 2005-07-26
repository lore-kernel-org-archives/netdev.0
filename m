From: Matt Mackall <mpm@selenic.com>
Subject: Re: [2.6 patch] NETCONSOLE must depend on INET
Date: Tue, 26 Jul 2005 16:20:43 -0700
Message-ID: <20050726232043.GB7425@waste.org>
References: <20050719182919.GA5531@stusta.de> <20050719.140104.68160812.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bunk@stusta.de, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262339AbVGZXVG@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050719.140104.68160812.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 19, 2005 at 02:01:04PM -0700, David S. Miller wrote:
> From: Adrian Bunk <bunk@stusta.de>
> Date: Tue, 19 Jul 2005 20:29:19 +0200
> 
> > NETCONSOLE=y and INET=n results in the following compile error:
> 
> Also applied, thanks Adrian.

I should have been cc:ed on this.

This problem also exists in PKTGEN. And this fix is incorrect as
neither is dependent on the IP part of the networking stack in any
substantive way. The right fix is to make inet_aton available outside
of CONFIG_INET (preferred) or making private copies of inet_aton.

-- 
Mathematics is the supreme nostalgia of our time.
