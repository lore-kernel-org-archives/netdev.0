From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] SH7619: fix Ether support
Date: Tue, 20 Aug 2013 17:05:23 -0700 (PDT)
Message-ID: <20130820.170523.1476358382284760995.davem@davemloft.net>
References: <201308180213.23296.sergei.shtylyov@cogentembedded.com>
	<201308180215.43063.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201308180215.43063.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 18 Aug 2013 02:15:42 +0400

> The 'sh_eth' driver's probe will crash as the platform code is hopelessly behind
> the platform data -- it passes PHY ID instead of 'struct sh_eth_plat_data *'.
> Strangely, both commit d88a3ea6fa4c (SH7619 add ethernet controler support) that
> added the platform code and commit 71557a37adb5 ([netdrvr] sh_eth: Add  SH7619
> support)  were done  in about  the same time, yet the latter one added 'struct
> sh_eth_plat_data' and the platform code didn't ever get updated...
> 
> Add the proper platform data and fix off-by-one memory resource end error, while
> at it...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
